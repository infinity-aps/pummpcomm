defmodule Pummpcomm.Session.Exchange.ReadInsulinSensitivities do
  use Bitwise
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0x8B
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  @max_count 8
  def decode(%Response{opcode: @opcode, data: <<units::8, rest::binary>>}) do
    {:ok, %{units: decode_units(units), sensitivities: decode_sensitivity(rest, [], @max_count, units)}}
  end

  defp decode_sensitivity(_, decoded_sensitivities, 0, _), do: Enum.reverse(decoded_sensitivities)
  defp decode_sensitivity(<<_::2, 0::6, _::binary>>, decoded_sensitivities, _, _) when length(decoded_sensitivities) > 0, do: Enum.reverse(decoded_sensitivities)
  defp decode_sensitivity(<<0::1, sensitivity_high::1, start_time::6, sensitivity_low::8, rest::binary>>, decoded_sensitivities, count, units) do
    sensitivity = (sensitivity_high <<< 8) + sensitivity_low
    decoded = %{start: basal_time(start_time), sensitivity: convert_sensitivity_value(units, sensitivity)}
    decode_sensitivity(rest, [decoded | decoded_sensitivities], count - 1, units)
  end

  @mgdl 1
  @mmol 2
  defp decode_units(@mgdl), do: "mg/dL"
  defp decode_units(@mmol), do: "mmol/L"

  defp convert_sensitivity_value(@mgdl, sensitivity), do: sensitivity
  defp convert_sensitivity_value(@mmol, sensitivity), do: sensitivity / 10

  defp basal_time(raw_time) do
    :local
    |> Timex.now()
    |> Timex.beginning_of_day()
    |> Timex.shift(minutes: 30 * raw_time)
    |> DateTime.to_time()
  end
end
