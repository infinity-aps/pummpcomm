defmodule Pummpcomm.Driver.SubgRfspy do
  @moduledoc """
  This module models the serial communications with a chip running the subg_rfspy firmware
  (https://github.com/ps2/subg_rfspy) capable of talking to a wireless insulin pump. It takes packet commands destined
  for the insulin pump, converts them to 4x6, and wraps them in a command that the subg_rfspy firmware knows how to
  process. The lower level serial communication is handled by a serial driver such as Pummpcomm.Driver.SubgRfspy.UART.
  """

  require Logger
  use Bitwise
  alias Pummpcomm.Driver.FourBySix

  @serial_driver Application.get_env(:pummpcomm, :serial_driver)
  @serial_timeout_ms_padding 1000

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

  def update_register(register, value) do
    write_command(<<register::8, value::8>>, :update_register, 1000)
    {:ok}
  end

  def set_base_frequency(mhz) do
    freq_xtal = 24_000_000
    val = round((mhz * 1_000_000) / (freq_xtal / :math.pow(2, 16)))
    update_register(@registers[:freq0], val &&& 0xff)
    update_register(@registers[:freq1], (val >>> 8) &&& 0xff)
    update_register(@registers[:freq2], (val >>> 16) &&& 0xff)
    flush_response_buffer()
    {:ok}
  end

  def read(timeout_ms \\ 1000) do
    write_command(<<@channel::8, timeout_ms::32>>, :get_packet, timeout_ms + 1000)
    timeout_ms |> read_response() |> process_response()
  end

  def write(packet, repetitions \\ 1, repetition_delay \\ 0, timeout_ms \\ 1000) do
    write_batches(packet, repetitions, repetition_delay, timeout_ms)
    read_response(timeout_ms)
  end

  def write_and_read(packet, timeout_ms \\ 500) do
    {:ok, encoded} = FourBySix.encode(packet)
    <<@channel::8, @repetitions::8, @repetition_delay::8,
      @channel::8, timeout_ms::size(32), @retry_count::8,
      encoded::binary>>
      |> write_command(:send_and_listen, timeout_ms + @serial_timeout_ms_padding)
    timeout_ms |> read_response() |> process_response()
  end

  def reset do
    :ok = write_command(<<>>, :reset, 100)
  end

  def sync do
    flush_response_buffer()
    {:ok, status} = get_state()
    {:ok, version} = get_version()
    %{status: status, version: version}
  end

  def get_version do
    :ok = write_command(<<>>, :get_version, 100)
    read_response(5000)
  end

  def get_state do
    :ok = write_command(<<>>, :get_state, 100)
    read_response(5000)
  end

  def flush_response_buffer(times \\ 4) do
    (0..times) |> Enum.each(fn(_) -> read_response(50) end)
  end

  @max_repetition_batch_size 250
  defp write_batches(packet, repetitions, repetition_delay, timeout_ms)  do
    {:ok, encoded} = FourBySix.encode(packet)
    <<@channel::8, repetitions::8, repetition_delay::8, encoded::binary>>
    |> write_command(:send_packet, timeout_ms)

    if repetitions > @max_repetition_batch_size do
      write_batches(packet, repetitions - @max_repetition_batch_size, repetition_delay, timeout_ms)
    end
  end

  defp write_command(param, command_type, timeout_ms) do
    command = @commands[command_type]
    response = @serial_driver.write(<<command::8>> <> param, timeout_ms + 10_000)
    if command_type == :reset do
      :timer.sleep(5000)
    end
    response
  end

  @timeout             0xAA
  @command_interrupted 0xBB
  @zero_data           0xCC
  defp read_response(timeout_ms) do
    response = @serial_driver.read(timeout_ms)
    case response do
      {:ok, <<@command_interrupted>>} ->
        Logger.debug fn -> "Command Interrupted, continuing to read" end
        read_response(timeout_ms)
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
        {:ok, %{rssi: rssi(raw_rssi), sequence: sequence, data: decoded}}
      other = {:error, _} -> other
    end
  end

  @rssi_offset 73
  defp rssi(raw_rssi) when raw_rssi >= 128, do: rssi(raw_rssi - 256)
  defp rssi(raw_rssi), do: (raw_rssi / 2) - @rssi_offset
end
