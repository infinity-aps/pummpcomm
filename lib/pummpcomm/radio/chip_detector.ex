defmodule Pummpcomm.Radio.ChipDetector do
  @moduledoc """
  This module autodetects a compatible pump chip and returns a struct with the serial/pin configuration
  """

  alias RFM69.Device, as: RFM69SPI
  alias SubgRfspy.SPI, as: SubgRfspySPI

  @chips [
    %SubgRfspySPI{name: :explorer_board, device: "spidev0.0", reset_pin: 4},
    %RFM69SPI{name: :ecc1_phat, device: "spidev0.0", reset_pin: 24, interrupt_pin: 23}
  ]

  def autodetect do
    @chips |> Enum.find(&detect_chip/1)
  end

  defp detect_chip(chip = %SubgRfspySPI{}), do: SubgRfspySPI.chip_present?(chip)
  defp detect_chip(chip = %RFM69SPI{}), do: RFM69SPI.chip_present?(chip)
end
