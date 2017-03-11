defmodule Pummpcomm.SerialLink do
  use GenServer

  def start_link(device) do
    {:ok, serial_pid} = Nerves.UART.start_link
    :ok = Nerves.UART.open(serial_pid, device, speed: 19200, active: false)
    :ok = Nerves.UART.configure(serial_pid, framing: {Nerves.UART.Framing.Line, separator: <<0x00>>})

    GenServer.start_link(__MODULE__, serial_pid, name: __MODULE__)
  end

  def update_register(register, value, timeout \\ 1) do
    GenServer.call(__MODULE__, {:update_register, register, value, timeout})
  end

  def read(timeout_ms \\ 500) do
    GenServer.call(__MODULE__, {:read, timeout_ms})
  end

  def write_and_read(command_bytes, repetitions \\ 1, repetition_delay \\ 0, timeout_ms \\ 500) do
    GenServer.call(__MODULE__, {:write_and_read, command_bytes, repetitions, repetition_delay, timeout_ms})
  end

  @channel 0
  @retry_count 0
  def handle_call({:write_and_read, command_bytes, repetitions, repetition_delay, timeout_ms}, serial_pid) do
    chip_bytes = <<@channel::8, (repetitions - 1)::8, repetition_delay::8, @channel::8, timeout_ms::32, @retry_count::8>>
    pump_bytes = command_bytes |> Pummpcomm.FourBySix.encode
    {:ok, response_bytes} = do_command(serial_pid, :send_and_listen, chip_bytes <> pump_bytes, timeout_ms)
    {:reply, response_bytes, serial_pid}
  end

  def handle_call({:read, timeout_ms}, serial_pid) do
    bytes = <<@channel::8, timeout_ms::32>>
    {:ok, response_bytes} = do_command(serial_pid, :get_packet, bytes, timeout_ms + 1000)
    {:reply, response_bytes, serial_pid}
  end



  @commands %{
    get_state:       0x01,
    get_version:     0x02,
    get_packet:      0x03,
    send_packet:     0x04,
    send_and_listen: 0x05,
    update_register: 0x06,
    reset:           0x07
  }

  def do_command(_, _, _, timeout_ms) when timeout_ms <= 0 or timeout_ms == nil, do: {:error, "timeout_ms must be positive"}
  def do_command(serial_pid, command_type, param, timeout_ms) do
    send_command(serial_pid, command_type, param, timeout_ms)
    if command_type == :reset do
      :timer.sleep(5000)
    end
    get_response(serial_pid, timeout_ms)
  end

  def send_command(_, _, _, timeout_ms) when timeout_ms <= 0 or timeout_ms == nil, do: {:error, "timeout_ms must be positive"}
  def send_command(serial_pid, command_type, param, timeout_ms) do
    command = @commands[command_type]
    Nerves.UART.write(serial_pid, <<command::8>> <> param, timeout_ms)
  end

  def get_response(_, timeout_ms) when timeout_ms <= 0 or timeout_ms == nil, do: {:error, "timeout_ms must be positive"}
  def get_response(serial_pid, timeout_ms) do
    response = Nerves.UART.read(serial_pid, timeout_ms) |> process_response
    case response do
      # {:command_interrupted} -> get_response(serial_pid, timeout_ms)
      response = {:ok, _}    -> response
    end
  end

  def sync(_, timeout_ms) when timeout_ms <= 0 or timeout_ms == nil, do: {:error, "timeout_ms must be positive"}
  def sync(serial_pid, timeout_ms) do
    send_command(serial_pid, :get_state, <<>>, timeout_ms)
    {:ok, status} = get_response(serial_pid, timeout_ms)
    IO.puts status
    send_command(serial_pid, :get_version, <<>>, timeout_ms)
    {:ok, version} = get_response(serial_pid, timeout_ms)
    IO.puts version
  end

  @command_interrupted 0xBB
  defp process_response({:ok, <<>>}), do: {:empty}
  defp process_response({:ok, data = <<@command_interrupted::8, _::binary>>}) when byte_size(data) <= 2, do: {:command_interrupted}
  defp process_response({:ok, data}), do: {:ok, data}
end
