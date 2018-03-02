defmodule Pummpcomm.Radio.ChipDetector do
  @moduledoc """
  This module autodetects a compatible pump chip and returns a struct with the serial/pin configuration
  """

  require Logger

  alias RFM69.Device, as: RFM69SPI
  alias SubgRfspy.SPI, as: SubgRfspySPI
  alias SubgRfspy.UART, as: SubgRfspyUART

  def autodetect do
    (Application.get_env(:pummpcomm, :autodetect_chips, []) ++ enumerated_uarts())
    |> Enum.find(&detect_chip/1)
  end

  defp enumerated_uarts do
    Nerves.UART.enumerate()
    |> Enum.filter(fn {device, _} -> String.contains?(device, "usb") end)
    |> Enum.map(fn {device, _} ->
      %{__struct__: SubgRfspy.UART, name: :usb_uart, device: device}
    end)
  end

  defp detect_chip(chip = %RFM69SPI{}), do: RFM69SPI.chip_present?(chip)
  defp detect_chip(chip = %SubgRfspySPI{}), do: SubgRfspySPI.chip_present?(chip)
  defp detect_chip(chip = %SubgRfspyUART{}), do: SubgRfspyUART.chip_present?(chip)
end
