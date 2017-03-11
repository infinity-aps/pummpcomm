defmodule Pummpcomm.History.MealMarker do
  use Bitwise
  alias Pummpcomm.DateDecoder

  def decode(<<_::7, carb_high_bit::1, timestamp::binary-size(5), carb_low_bits::8, _::6, unit_bit::1, _::1>>, _) do
    units = units(unit_bit)
    %{
      carbohydrates: carbohydrates(carb_high_bit, carb_low_bits, units),
      carb_units: units,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  defp units(0x00), do: :grams
  defp units(0x01), do: :exchanges

  defp carbohydrates(_,             carb_low_bits, :exchanges), do: carb_low_bits / 10.0
  defp carbohydrates(carb_high_bit, carb_low_bits, :grams),     do: (carb_high_bit <<< 8) + carb_low_bits
end
