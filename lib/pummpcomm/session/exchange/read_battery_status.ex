defmodule Pummpcomm.Session.Exchange.ReadBatteryStatus do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0x72
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  def decode(%Response{opcode: @opcode, data: <<indicator::8, raw_voltage::size(16), _rest::binary>>}) do
    {:ok, %{indicator: decode_indicator(indicator), voltage: raw_voltage / 100.0}}
  end

  defp decode_indicator(0), do: :normal
  defp decode_indicator(1), do: :low
end
