defmodule Pummpcomm.Session.PumpExecutor do
  require Logger
  alias Pummpcomm.Session.Context
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Packet
  alias Pummpcomm.Driver.SubgRfspy

  def wait_for_silence() do
    # Logger.debug "Waiting for silence"
    with {:ok, %{data: <<0xA7::size(8), _::binary>>}} <- SubgRfspy.read(5000) do
      Logger.debug fn -> "Detected pump radio comms" end
      wait_for_silence()
    else
      {:error, :timeout} ->
        # Logger.debug "No radio comms detected"
        {:ok}
      other              ->
        Logger.debug fn -> "Detected other comms. Retrying" end
        wait_for_silence()
    end
  end

  @retry_count 3
  def execute(command, retry_count \\ @retry_count) do
    _execute(command, retry_count)
  end

  @fast_timeout 1
  def repeat_execute(command, times, ack_wait_millis) when times > 255 do
    _repeat_execute(command, 255, @fast_timeout)
    repeat_execute(command, times - 255, ack_wait_millis)
  end

  def repeat_execute(command, times, ack_wait_millis) do
    _repeat_execute(command, times, ack_wait_millis)
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

  defp _repeat_execute(command, times, ack_wait_millis) do
    {:ok, command_packet} = Packet.from_command(command, Command.short_payload(command))
    command_bytes = Packet.to_binary(command_packet)

    with {:ok, ""} <- SubgRfspy.write(command_bytes, times, 0, 24 * times) do
      case wait_for_ack(%Context{command: command}, ack_wait_millis) do
        %Context{error: nil} -> true
        %Context{error: reason} ->
          Logger.error "Repeat execute errored with reason #{reason}", command: command
          false
      end
    else
      {:error, reason} ->
        Logger.error "errored with reason #{reason}", command: command
      false
    end
  end

  defp send_command(command) do
    %Context{command: command} |> do_prelude |> do_upload
  end

  defp do_prelude(context = %Context{error: error}) when error != nil, do: context
  defp do_prelude(context = %Context{command: command}) do
    {:ok, packet} = Packet.from_command(command, <<0x00>>)
    # Logger.info "Sending prelude packet: #{inspect(packet)}"
    command_bytes = Packet.to_binary(packet)
    with {:ok, %{data: response_bytes}} <- SubgRfspy.write_and_read(command_bytes),
         {:ok, response_packet} <- Packet.from_binary(response_bytes),
         {:ok} <- validate_response_packet(command.pump_serial, response_packet) do

      # Logger.info "Response Packet: #{inspect(response_packet)}"
      case response_packet do
        %{opcode: 0x06} -> Context.received_ack(context)
        _               -> Context.add_response(context, response_packet)
      end
    else
      {:error, reason} ->
        message = "do_prelude errored with reason #{reason}"
        # Logger.error message, context: context
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
    with {:ok, %{data: response_bytes}} <- SubgRfspy.read(timeout),
      {:ok, response_packet} <- Packet.from_binary(response_bytes),
      {:ok} <- validate_response_packet(context.command.pump_serial, response_packet) do

      # Logger.info "Response Packet: #{inspect(response_packet)}"
      case response_packet do
        %{opcode: 0x06} -> Context.received_ack(context)
        _               -> wait_for_ack(context, timeout)
      end
    else
      {:error, reason} ->
        message = "wait_for_ack errored with reason #{reason}"
        # Logger.error message, context: context
        Context.add_error(context, message)
    end
  end

  defp ack_and_listen(context = %Context{response: response}) do
    pump_serial = context.command.pump_serial
    command = Command.ack(pump_serial)
    {:ok, ack_packet} = Packet.from_command(command, Command.short_payload(command))
    # Logger.info "Sending ack packet: #{inspect(ack_packet)}"
    command_bytes = Packet.to_binary(ack_packet)

    case response.last_frame? do
      true ->
        {:ok, _} = SubgRfspy.write(command_bytes)
        context
      false ->
        with {:ok, %{data: response_bytes}} <- SubgRfspy.write_and_read(command_bytes, 100),
             {:ok, response_packet = %{pump_serial: ^pump_serial}} <- Packet.from_binary(response_bytes) do
          # Logger.info "Response Packet from send params: #{inspect(response_packet)}"

          context
          |> Context.sent_params()
          |> Context.add_response(response_packet)
          |> ack_and_listen()
        end
    end
  end

  defp send_params(context = %Context{command: command}) do
    # Logger.info "Sending params: #{inspect(command)}"
    pump_serial = command.pump_serial
    {:ok, packet} = Packet.from_command(command)
    # Logger.info "Sending params packet: #{inspect(packet)}"
    command_bytes = Packet.to_binary(packet)
    with {:ok, %{data: response_bytes}} <- SubgRfspy.write_and_read(command_bytes),
         {:ok, response_packet = %{pump_serial: ^pump_serial}} <- Packet.from_binary(response_bytes) do

      # Logger.info "Response Packet from send params: #{inspect(response_packet)}"

      context
      |> Context.sent_params()
      |> Context.add_response(response_packet)
      |> ack_and_listen()
    else
      {:error, msg} ->
        # Logger.error "Error: #{inspect(msg)}"
        SubgRfspy.write(command_bytes)
        Context.sent_params(context)
    {:ok, response_packet} ->
        message = "Received packet for another pump with serial #{response_packet.pump_serial}"
        # Logger.error message, context: context, packet: packet
        Context.add_error(context, message)
    end
  end
end
