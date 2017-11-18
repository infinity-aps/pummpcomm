defprotocol Pummpcomm.Radio.Chip do
  @fallback_to_any true

  def set_base_frequency(chip, mhz)
  def read(chip, timeout_ms)
  def write(chip, packet, repetition, repetition_delay, timeout_ms)
  def write_and_read(chip, packet, timeout_ms)
  def configure(chip)
end

defimpl Pummpcomm.Radio.Chip, for: SubgRfspy.SPI do
  defdelegate set_base_frequency(chip, mhz), to: SubgRfspy
  defdelegate read(chip, timeout_ms), to: SubgRfspy
  defdelegate write(chip, packet, repetition, repetition_delay, timeout_ms), to: SubgRfspy
  defdelegate write_and_read(chip, packet, timeout_ms), to: SubgRfspy
  def configure(_), do: :ok
end

defimpl Pummpcomm.Radio.Chip, for: SubgRfspy.UART do
  defdelegate set_base_frequency(chip, mhz), to: SubgRfspy
  defdelegate read(chip, timeout_ms), to: SubgRfspy
  defdelegate write(chip, packet, repetition, repetition_delay, timeout_ms), to: SubgRfspy
  defdelegate write_and_read(chip, packet, timeout_ms), to: SubgRfspy
  def configure(_), do: :ok
end

defimpl Pummpcomm.Radio.Chip, for: RFM69.Device do
  defdelegate set_base_frequency(chip, mhz), to: RFM69
  defdelegate read(chip, timeout_ms), to: RFM69
  defdelegate write(chip, packet, repetition, repetition_delay, timeout_ms), to: RFM69
  defdelegate write_and_read(chip, packet, timeout_ms), to: RFM69

  def configure(chip) do
    configuration = %RFM69.Configuration{
      op_mode: 0x00,
      frf: RFM69.Configuration.frequency_to_registers(916_600_000),
      bitrate: RFM69.Configuration.bitrate_to_registers(16_384),
      data_modul: 0x08,
      pa_level: 0x5F,
      lna: 0x88,
      rx_bw: 0x40, # 250kHz with dcc freq shift 2, RxBwMant of 16 and RxBwExp of 0
      afc_bw: 0x80, # dcc freq shift of 4
      dio_mapping1: 0x80,
      dio_mapping2: 0x07,
      rssi_thresh: 0xE4,
      preamble: 0x0018,
      sync_config: 0x98,
      sync_value: 0xFF00FF0001010101,
      packet_config1: 0x00,
      payload_length: 0x00,
      fifo_thresh: 0x94,
      packet_config2: 0x00
    }
    RFM69.write_configuration(chip, configuration)
    :ok
  end
end

defimpl Pummpcomm.Radio.Chip, for: Any do
  def set_base_frequency(chip, _), do: {:error, "No Chip implementation found for #{inspect chip}"}
  def read(chip, _), do: {:error, "No Chip implementation found for #{inspect chip}"}
  def write(chip, _, _, _, _), do: {:error, "No Chip implementation found for #{inspect chip}"}
  def write_and_read(chip, _, _), do: {:error, "No Chip implementation found for #{inspect chip}"}
  def configure(chip), do: {:error, "No Chip implementation found for #{inspect chip}"}
end
