defmodule Pummpcomm.Command do
  @enforce_keys [:opcode, :pump_serial]
  defstruct opcode: nil, params: <<>>, pump_serial: nil, retries: 2, timeout: 3, bytes_per_record: 64, max_records: 1,
    effect_time: 0.5

  def payload(%Pummpcomm.Command{params: params}) do
    params_count = byte_size(params)
    filler_length = (63 - params_count) * 8
    <<params_count::size(8)>> <> params <> <<0::size(filler_length)>>
  end
end

defmodule Pummpcomm.Context do
  defstruct command: nil, received_ack: false, error: nil
end

defmodule Pummpcomm.Session do
  alias Pummpcomm.Command
  alias Pummpcomm.Context
  alias Pummpcomm.Packet
  alias Pummpcomm.SerialLink

  @retry_count 3
  def execute(command, retry_count \\ @retry_count) do
    _execute(command, retry_count)
  end

  defp _execute(_, 0), do: {:error, "Max timeouts reached"}
  defp _execute(command, retry_count) do
    case send_command(command) do
      {:error, _} -> _execute(command, retry_count - 1)
      {:ok, result}     -> {:ok, result}
    end
  end

  def send_command(command, retry_count \\ @retry_count) do
    _send_command(command, retry_count)
  end

  defp _send_command(_, 0), do: {:error, "Max timeouts reached"}
  defp _send_command(command, retry_count) do
    %Context{command: command}
    |> do_prelude
    |> do_upload

    # ...
  end

  defp do_prelude(context = %Context{error: error}) when error != nil, do: context
  defp do_prelude(context = %Context{command: command}) do
    {:ok, command_bytes} = Packet.from_command(command, <<0x00>>) |> Packet.to_binary
    {:ok, response_bytes} = SerialLink.write_and_read(command_bytes)
    {:ok, response_packet} = Packet.from_binary(response_bytes)
    pump_serial = command.pump_serial

    case response_packet do
      %{pump_serial: ^pump_serial, opcode: 0x06} -> %{context | received_ack: true}
      %{pump_serial: ^pump_serial}               -> respond(response_packet)
      _                                          -> %{context | error: "Invalid packet received"}
    end
  end

  defp do_upload(context = %Context{error: error}) when error != nil, do: context
  defp do_upload(context = %Context{command: %Command{params: params}}) when byte_size(params) == 0 do
    %{context | params_done: true}
  end

  defp do_upload(context = %Context{received_ack: received_ack}) do
    case received_ack do
      false -> wait_for_ack(context)
      true  -> send_params(context)
    end
  end

  @timeout 500
  defp wait_for_ack(context) do
    {:ok, response_bytes} = SerialLink.read(@timeout)
    # more things here until done
    context
  end

  defp send_params(context = %Context{command: command}) do
    {:ok, command_bytes} = Packet.from_command(command) |> Packet.to_binary
    #more things here
    context
  end

  defp respond(response) do

  end
end
