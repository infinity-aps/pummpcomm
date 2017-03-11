defmodule Pummpcomm.History.UnabsorbedInsulin do
  use Bitwise

  def event_length(%{body_and_tail: <<length::8, _::binary>>}), do: max((length), 2)

  def decode(<<_length::8, body::binary>>, _) do
    %{data: decode_unabsorbed_insulin(body, [])}
  end

  defp decode_unabsorbed_insulin(<<>>, records), do: records |> Enum.reverse
  defp decode_unabsorbed_insulin(<<amount::8, age_lower_bits::8, _::2, age_higher_bits::2, _::4, tail::binary>>, records) do
    record = %{
      age: (age_higher_bits <<< 8) + age_lower_bits,
      amount: amount / 40.0
    }
    decode_unabsorbed_insulin(tail, [record | records])
  end
end
