defmodule Pummpcomm.Session.Exchange.ReadCarbRatios do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0x8A
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  def decode(%Response{opcode: @opcode, data: <<units::8, count::8, rest::binary>>}, model_number) when rem(model_number, 100) >= 23 do
    %{units: decode_units(units), schedule: decode_larger_carb_ratio(rest, [], count)}
  end

  def decode(%Response{opcode: @opcode, data: <<units::8, rest::binary>>}, _) do
    %{units: decode_units(units), schedule: decode_smaller_carb_ratio(rest, [], 8)}
  end

  defp decode_larger_carb_ratio(_, carb_ratios, count) when count == 0, do: Enum.reverse(carb_ratios)
  defp decode_larger_carb_ratio(<<raw_time::8, raw_ratio::binary-size(2), rest::binary>>, carb_ratios, count) do
    carb_ratio = %{ratio: decode_ratio(raw_ratio), start: basal_time(raw_time)}
    decode_larger_carb_ratio(rest, [carb_ratio | carb_ratios], count - 1)
  end

  defp decode_smaller_carb_ratio(_, carb_ratios, count) when count == 0, do: Enum.reverse(carb_ratios)
  defp decode_smaller_carb_ratio(<<_::8, raw_ratio::8, _::binary>>, carb_ratios, _) when raw_ratio == 0 and length(carb_ratios) > 0, do: Enum.reverse(carb_ratios)
  defp decode_smaller_carb_ratio(<<raw_time::8, raw_ratio::binary-size(1), rest::binary>>, carb_ratios, count) do
    carb_ratio = %{ratio: decode_ratio(raw_ratio), start: basal_time(raw_time)}
    decode_smaller_carb_ratio(rest, [carb_ratio | carb_ratios], count - 1)
  end

  defp decode_ratio(<<raw_ratio::8>>), do: raw_ratio / 1
  defp decode_ratio(<<0x00::8, raw_ratio::8>>), do: raw_ratio / 10
  defp decode_ratio(<<raw_ratio::16>>), do: raw_ratio / 1000

  defp basal_time(raw_time) do
    :local
    |> Timex.now()
    |> Timex.beginning_of_day()
    |> Timex.shift(minutes: 30 * raw_time)
    |> DateTime.to_time()
  end

  defp decode_units(0x01), do: :grams
  defp decode_units(0x02), do: :exchanges
end
