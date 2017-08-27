defmodule Pummpcomm.Session.Exchange.ReadBgTargets do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0x9F
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  @targets_max_count 8
  def decode(%Response{opcode: @opcode, data: <<units::8, targets::binary>>}) do
    {:ok, %{units: decode_units(units), targets: decode_targets(units, targets, [], @targets_max_count)}}
  end

  defp decode_targets(_, _, decoded_targets, 0), do: Enum.reverse(decoded_targets)

  defp decode_targets(_, <<0::8, _::binary>>, decoded_targets, _) when length(decoded_targets) > 0, do: Enum.reverse(decoded_targets)

  defp decode_targets(units, <<raw_start_time::8, bg_low::8, bg_high::8, rest::binary>>, decoded_targets, count) do
    target = %{start: basal_time(raw_start_time), bg_low: decode_bg(bg_low, units), bg_high: decode_bg(bg_high, units)}
    decode_targets(units, rest, [target | decoded_targets], count - 1)
  end

  @mgdl 1
  @mmol 2
  defp decode_units(@mgdl), do: "mg/dL"
  defp decode_units(@mmol), do: "mmol/L"

  defp decode_bg(bg, @mgdl), do: bg
  defp decode_bg(bg, @mmol), do: bg / 10

  defp basal_time(raw_time) do
    :local
    |> Timex.now()
    |> Timex.beginning_of_day()
    |> Timex.shift(minutes: 30 * raw_time)
    |> DateTime.to_time()
  end
end
