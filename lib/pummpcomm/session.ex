defmodule Pummpcomm.Session do
  alias Pummpcomm.Context
  alias Pummpcomm.Command
  alias Pummpcomm.Response
  alias Pummpcomm.Packet
  alias Pummpcomm.SerialLink

  def power_control(pump_serial) do
    case check_pump_awake(pump_serial) do
      true  -> true
      false ->
        IO.puts "Sending power control command"
        result = Command.power_control(pump_serial)
        |> repeat_command(500, 12000)
        IO.inspect result
        result
    end
  end

  def check_pump_awake(pump_serial) do
    command = Command.read_pump_model(pump_serial)
    IO.puts "Checking to see if the pump is awake"
    IO.inspect(command)

    case execute(command) do
      {:ok, %Context{response: nil}} ->
        IO.puts "Received no response"
        false
      {:ok, %Context{response: response}} ->
        IO.puts "Received positive response"
        IO.inspect Response.get_data(response)
        true
      result        ->
        IO.puts "Received negative result"
        IO.inspect result
        false
    end
  end

  @retry_count 3
  def execute(command, retry_count \\ @retry_count) do
    _execute(command, retry_count)
  end

  defp _execute(_, -1), do: {:error, "Max retries reached"}
  defp _execute(command, retry_count) do
    case send_command(command) do
      {:error, _} -> _execute(command, retry_count - 1)
      {:ok, context}     -> {:ok, context}
    end
  end

  def send_command(command, retry_count \\ @retry_count) do
    _send_command(command, retry_count)
  end

  defp _send_command(_, -1), do: {:error, "Max retries reached"}
  defp _send_command(command, retry_count) do
    context = %Context{command: command}
    |> do_prelude
    |> do_upload

    case context do
      %Context{error: nil} -> {:ok, context}
      _ -> {:error, context}
    end
  end

  defp repeat_command(command, times, ack_wait_millis) do
    {:ok, command_packet} = Packet.from_command(command, Command.short_payload(command))
    command_bytes = Packet.to_binary(command_packet)

    with {:ok, ""} <- SerialLink.write(command_bytes, times, 0, 24 * times) do
      :timer.sleep 10000
      case wait_for_ack(%Context{command: command}, ack_wait_millis) do
        context = %Context{error: error} ->
          IO.inspect context
          false
        _                      -> true
      end
    else
      {:error, reason} ->
        message = "Errored with reason #{reason}"
        IO.puts message
        false
    end
  end

  defp do_prelude(context = %Context{error: error}) when error != nil, do: context
  defp do_prelude(context = %Context{command: command}) do
    {:ok, packet} = Packet.from_command(command, <<0x00>>)
    IO.puts "Sending prelude packet"
    IO.inspect packet
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
        message = "Errored with reason #{reason}"
        IO.puts message
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
        message = "Errored with reason #{reason}"
      IO.puts message
      Context.add_error(context, message)
    end
  end

  defp send_params(context = %Context{command: command}) do
    pump_serial = command.pump_serial
    {:ok, packet} = Packet.from_command(command)
    {:ok, command_bytes} = Packet.to_binary(packet)
    with {:ok, %{data: response_bytes}} <- SerialLink.write_and_read(command_bytes),
         {:ok, response_packet = %{pump_serial: ^pump_serial}} <- Packet.from_binary(response_bytes) do
      Context.add_response(context, response_packet)
    else
      {:error, _} -> SerialLink.write(command_bytes)
      {:ok, response_packet} -> IO.puts "Received packet for another pump: #{IO.inspect(response_packet)}"
    end
    %{context | sent_params: true}
  end
end
