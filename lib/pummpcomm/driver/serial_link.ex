defmodule Pummpcomm.Driver.SerialLink do
  require Logger
  use GenServer
  use Bitwise
  alias Pummpcomm.Driver.SerialFraming
  alias Pummpcomm.Driver.FourBySix

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

  @registers %{
    freq2:    0x09,
    freq1:    0x0A,
    freq0:    0x0B,
    mdmcfg4:  0x0C,
    mdmcfg3:  0x0D,
    mdmcfg2:  0x0E,
    mdmcfg1:  0x0F,
    mdmcfg0:  0x10,
    agcctrl2: 0x17,
    agcctrl1: 0x18,
    agcctrl0: 0x19,
    frend1:   0x1A,
    frend0:   0x1B
  }

  # Public API

  def start_link(device) do
    {:ok, serial_pid} = Nerves.UART.start_link
    :ok = Nerves.UART.open(serial_pid, device, speed: 19200, active: false)
    :ok = Nerves.UART.configure(serial_pid, framing: {SerialFraming, separator: <<0x00>>})
    :ok = Nerves.UART.flush(serial_pid)

    GenServer.start_link(__MODULE__, serial_pid, name: __MODULE__)
  end

  def update_register(register, value, timeout_ms \\ 1) do
    GenServer.call(__MODULE__, {:update_register, register, value, timeout_ms}, @genserver_timeout)
  end

  def set_base_frequency(mhz) do
    GenServer.call(__MODULE__, {:set_base_frequency, mhz}, @genserver_timeout)
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

  def handle_call({:update_register, register, value, timeout_ms}, _from, serial_pid) do
    _update_register(@registers[register], value, serial_pid)
    {:reply, {:ok}, serial_pid}
  end

  def handle_call({:set_base_frequency, mhz}, _from, serial_pid) do
    freq_xtal = 24000000
    val = round((mhz * 1000000) / (freq_xtal / :math.pow(2, 16)))
    #puts "Updating freq: 0x#{val.to_s(16)}"
    _update_register(@registers[:freq0], val &&& 0xff, serial_pid)
    _update_register(@registers[:freq1], (val >>> 8) &&& 0xff, serial_pid)
    _update_register(@registers[:freq2], (val >>> 16) &&& 0xff, serial_pid)
    {:reply, {:ok}, serial_pid}
  end

  def handle_call({:read, timeout_ms}, _from, serial_pid) do
    write_command(<<@channel::8, timeout_ms::32>>, :get_packet, serial_pid, timeout_ms + 1000)
    response = read_response(serial_pid, timeout_ms) |> process_response()
    {:reply, response, serial_pid}
  end

  def handle_call({:write_and_read, command_bytes, timeout_ms}, _from, serial_pid) do
    Logger.debug "Command bytes: #{Base.encode16(command_bytes)}"
    {:ok, encoded} = FourBySix.encode(command_bytes)
    <<@channel::8, @repetitions::8, @repetition_delay::8,
      @channel::8, (timeout_ms+1000)::size(32), @retry_count::8,
      encoded::binary>>
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

  defp _update_register(register, value, serial_pid) do
    write_command(<<register::8, value::8>>, :update_register, serial_pid, 0)
  end

  @max_repetition_batch_size 250
  defp write_batches(command_bytes, repetitions, repetition_delay, timeout_ms, serial_pid)  do
    Logger.debug "Command bytes: #{Base.encode16(command_bytes)}"
    {:ok, encoded} = FourBySix.encode(command_bytes)
    <<@channel::8, repetitions::8, repetition_delay::8, encoded::binary>>
    |> write_command(:send_packet, serial_pid, timeout_ms)

    if repetitions > @max_repetition_batch_size do
      write_batches(command_bytes, repetitions - @max_repetition_batch_size, repetition_delay, timeout_ms, serial_pid)
    end
  end

  defp write_command(param, command_type, serial_pid, timeout_ms) do
    command = @commands[command_type]
    Logger.debug "Final command bytes look like: #{Base.encode16(<<command::8>> <> param)}"
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
    Logger.debug "Waiting for response with #{timeout_ms} timeout"
    response = Nerves.UART.read(serial_pid, timeout_ms + 10000)
    Logger.debug "Received response from UART: #{inspect response}"
    if {:ok, data} = response do
      Logger.debug "Response in hex: #{Base.encode16(data)}"
    end
    case response do
      {:ok, <<@command_interrupted>>} ->
        Logger.debug "Command Interrupted, continuing to read"
        read_response(serial_pid, timeout_ms)
      _ ->
        response
    end
  end

  defp process_response({:ok, <<>>}),                     do: {:error, :empty}
  defp process_response({:ok, <<@command_interrupted>>}), do: {:error, :command_interrupted}
  defp process_response({:ok, <<@timeout>>}),             do: {:error, :timeout}
  defp process_response({:ok, <<@zero_data>>}),           do: {:error, :zero_data}
  defp process_response({:ok, <<raw_rssi::8, sequence::8, data::binary>>}) do
    case FourBySix.decode(data) do
      {:ok, decoded}      ->
        Logger.debug "Decoded bytes: #{Base.encode16(decoded)}"
        {:ok, %{rssi: rssi(raw_rssi), sequence: sequence, data: decoded}}
      other = {:error, _} -> other
    end
  end

  @rssi_offset 73
  defp rssi(raw_rssi) when raw_rssi >= 128, do: rssi(raw_rssi - 256)
  defp rssi(raw_rssi), do: (raw_rssi / 2) - @rssi_offset
end
