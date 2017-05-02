defmodule Pummpcomm.Session.Pump do
  require Logger
  alias Pummpcomm.Session.Context
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Packet
  alias Pummpcomm.Driver.SerialLink

  def power_control(pump_serial) do
    case check_pump_awake(pump_serial) do
      true  -> true
      false ->
        Logger.info "Sending power control command"
        Command.power_control(pump_serial)
        |> repeat_command(500, 12000)
    end
  end

  def check_pump_awake(pump_serial) do
    case pump_serial |> Command.read_pump_model |> execute do
      {:ok, %Context{response: nil}}      -> false
      {:ok, %Context{response: _}}        -> true
      _                                   -> false
    end
  end

  @retry_count 3
  def execute(command, retry_count \\ @retry_count) do
    _execute(command, retry_count)
  end

  defp _execute(_, -1), do: {:error, "Max retries reached"}
  defp _execute(command, retry_count) do
    case send_command(command) do
      context = %Context{error: nil} ->
        {:ok, context}
      _ ->
        _execute(command, retry_count - 1)
    end
  end

  defp send_command(command) do
    %Context{command: command}
    |> do_prelude
    |> do_upload
  end

  defp repeat_command(command, times, ack_wait_millis) do
    {:ok, command_packet} = Packet.from_command(command, Command.short_payload(command))
    command_bytes = Packet.to_binary(command_packet)

    with {:ok, ""} <- SerialLink.write(command_bytes, times, 0, 24 * times) do
      case wait_for_ack(%Context{command: command}, ack_wait_millis) do
        %Context{error: nil} -> true
        %Context{error: reason} ->
          Logger.error "error with reason #{reason}", command: command
          false
      end
    else
      {:error, reason} ->
        Logger.error "errored with reason #{reason}", command: command
        false
    end
  end

  defp do_prelude(context = %Context{error: error}) when error != nil, do: context
  defp do_prelude(context = %Context{command: command}) do
    {:ok, packet} = Packet.from_command(command, <<0x00>>)
    Logger.info "Sending prelude packet", packet: packet
    command_bytes = Packet.to_binary(packet)
    with {:ok, %{data: response_bytes}} <- SerialLink.write_and_read(command_bytes, 1000),
         {:ok, response_packet} <- Packet.from_binary(response_bytes),
         {:ok} <- validate_response_packet(command.pump_serial, response_packet) do

      case response_packet do
        %{opcode: 0x06} -> Context.received_ack(context)
        _               -> Context.add_response(context, response_packet)
      end
    else
      {:error, reason} ->
        message = "error with reason #{reason}"
        Logger.error message, context: context
        Context.add_error(context, message)
    end
  end

  defp validate_response_packet(pump_serial, response_packet) do
    case response_packet do
      %{pump_serial: ^pump_serial} -> {:ok}
      _                            -> {:error, :crosstalk}
    end
  end

  defp do_upload(context = %Context{error: error}) when error != nil, do: context
  defp do_upload(context = %Context{command: %Command{params: params}}) when byte_size(params) == 0 do
    %{context | sent_params: true}
  end

  defp do_upload(context = %Context{received_ack: received_ack}) do
    case received_ack do
      false -> wait_for_ack(context)
      true  -> send_params(context)
    end
  end

  @timeout 500
  defp wait_for_ack(context, timeout \\ @timeout) do
    with {:ok, %{data: response_bytes}} <- SerialLink.read(timeout),
      {:ok, response_packet} <- Packet.from_binary(response_bytes),
      {:ok} <- validate_response_packet(context.command.pump_serial, response_packet) do

      case response_packet do
        %{opcode: 0x06} -> Context.received_ack(context)
        _               -> wait_for_ack(context, timeout)
      end
    else
      {:error, reason} ->
        message = "error with reason #{reason}"
        Logger.error message, context: context
        Context.add_error(context, message)
    end
  end

  defp send_params(context = %Context{command: command}) do
    pump_serial = command.pump_serial
    {:ok, packet} = Packet.from_command(command)
    {:ok, command_bytes} = Packet.to_binary(packet)
    with {:ok, %{data: response_bytes}} <- SerialLink.write_and_read(command_bytes),
         {:ok, response_packet = %{pump_serial: ^pump_serial}} <- Packet.from_binary(response_bytes) do

      context
      |> Context.sent_params()
      |> Context.add_response(response_packet)
    else
      {:error, _} ->
        SerialLink.write(command_bytes)
        Context.sent_params(context)
    {:ok, response_packet} ->
        message = "Received packet for another pump with serial #{packet.pump_serial}"
        Logger.error message, context: context, packet: packet
        Context.add_error(context, message)
    end
  end
end
