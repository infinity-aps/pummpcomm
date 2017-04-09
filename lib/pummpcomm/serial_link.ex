defmodule Pummpcomm.SerialLink do
  use GenServer

  @genserver_timeout 60000
  @channel 0
  @retry_count 0
  @repetitions 1
  @repetition_delay 0

  @commands %{
    get_state:       0x01,
    get_version:     0x02,
    get_packet:      0x03,
    send_packet:     0x04,
    send_and_listen: 0x05,
    update_register: 0x06,
    reset:           0x07
  }

  # Public API

  def start_link(device) do
    {:ok, serial_pid} = Nerves.UART.start_link
    :ok = Nerves.UART.open(serial_pid, device, speed: 19200, active: false)
    :ok = Nerves.UART.configure(serial_pid, framing: {Pummpcomm.SerialFraming, separator: <<0x00>>})
    :ok = Nerves.UART.flush(serial_pid)

    GenServer.start_link(__MODULE__, serial_pid, name: __MODULE__)
  end

  def update_register(register, value, timeout_ms \\ 1) do
    GenServer.call(__MODULE__, {:update_register, register, value, timeout_ms}, @genserver_timeout)
  end

  def read(timeout_ms \\ 5000) do
    GenServer.call(__MODULE__, {:read, timeout_ms}, @genserver_timeout)
  end

  def write(command_bytes, repetitions \\ 1, repetition_delay \\ 0, timeout_ms \\ 500) do
    GenServer.call(__MODULE__, {:write, command_bytes, repetitions, repetition_delay, timeout_ms}, @genserver_timeout)
  end

  def write_and_read(command_bytes, timeout_ms \\ 500) do
    GenServer.call(__MODULE__, {:write_and_read, command_bytes, timeout_ms}, @genserver_timeout)
  end

  def sync do
    GenServer.call(__MODULE__, {:sync}, @genserver_timeout)
  end

  # GenServer implementation

  def handle_call({:read, timeout_ms}, _from, serial_pid) do
    write_command(<<@channel::8, timeout_ms::32>>, :get_packet, serial_pid, timeout_ms + 1000)
    response = read_response(serial_pid, timeout_ms) |> process_response()
    {:reply, response, serial_pid}
  end

  def handle_call({:write_and_read, command_bytes, timeout_ms}, _from, serial_pid) do
    IO.puts "Command bytes"
    IO.puts Base.encode16(command_bytes)
    <<@channel::8, @repetitions::8, @repetition_delay::8,
      @channel::8, timeout_ms::size(32), @retry_count::8,
      Pummpcomm.FourBySix.encode(command_bytes)::binary>>
    |> write_command(:send_and_listen, serial_pid, timeout_ms)
    response = read_response(serial_pid, timeout_ms) |> process_response()
    {:reply, response, serial_pid}
  end

  def handle_call({:write, command_bytes, repetitions, repetition_delay, timeout_ms}, _from, serial_pid) do
    write_batches(command_bytes, repetitions, repetition_delay, timeout_ms, serial_pid)
    response = read_response(serial_pid, timeout_ms)
    {:reply, response, serial_pid}
  end

  def handle_call({:sync}, _from, serial_pid) do
    write_command(<<>>, :get_state, serial_pid, 1)
    {:ok, status} = read_response(serial_pid, 1)
    write_command(<<>>, :get_version, serial_pid, 1)
    {:ok, version} = read_response(serial_pid, 1)
    {:reply, %{status: status, version: version}, serial_pid}
  end

  # Private functions

  @max_repetition_batch_size 250
  defp write_batches(command_bytes, repetitions, repetition_delay, timeout_ms, serial_pid)  do
    IO.puts "Command bytes"
    IO.puts Base.encode16(command_bytes)
    <<@channel::8, repetitions::8, repetition_delay::8, Pummpcomm.FourBySix.encode(command_bytes)::binary>>
    |> write_command(:send_packet, serial_pid, timeout_ms)

    if repetitions > @max_repetition_batch_size do
      write_batches(command_bytes, repetitions - @max_repetition_batch_size, repetition_delay, timeout_ms, serial_pid)
    end
  end

  defp write_command(param, command_type, serial_pid, timeout_ms) do
    command = @commands[command_type]
    IO.puts "Final command bytes look like:"
    IO.puts(Base.encode16(<<command::8>> <> param))
    Nerves.UART.write(serial_pid, <<command::8>> <> param, timeout_ms + 10000)
    Nerves.UART.flush(serial_pid)
    if command_type == :reset do
      :timer.sleep(5000)
    end
  end

  @timeout             0xAA
  @command_interrupted 0xBB
  @zero_data           0xCC
  defp read_response(serial_pid, timeout_ms) do
    IO.puts "Waiting for response with #{timeout_ms} timeout"
    response = Nerves.UART.read(serial_pid, timeout_ms + 10000)
    IO.puts "Received response from UART:"
    IO.inspect response
    if {:ok, data} = response do
      IO.puts Base.encode16(data)
    end
    case response do
      {:ok, <<@command_interrupted>>} ->
        IO.puts "Command Interrupted, continuing to read"
        read_response(serial_pid, timeout_ms)
      _ ->
        response
    end
  end

  defp process_response({:ok, <<>>}),                            do: {:error, :empty}
  defp process_response({:ok, data = <<@command_interrupted>>}), do: {:error, :command_interrupted}
  defp process_response({:ok, data = <<@timeout>>}),             do: {:error, :timeout}
  defp process_response({:ok, data = <<@zero_data>>}),           do: {:error, :zero_data}
  defp process_response({:ok, <<raw_rssi::8, sequence::8, data::binary>>}) do
    decoded = Pummpcomm.FourBySix.decode(data)
    {:ok, %{rssi: rssi(raw_rssi), sequence: sequence, data: decoded}}
  end

  @rssi_offset 73
  defp rssi(raw_rssi) when raw_rssi >= 128, do: rssi(raw_rssi - 256)
  defp rssi(raw_rssi), do: (raw_rssi / 2) - @rssi_offset
end
