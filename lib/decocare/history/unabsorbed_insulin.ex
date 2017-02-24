defmodule Decocare.History.UnabsorbedInsulin do
  use Bitwise
  alias Decocare.DateDecoder, as: DateDecoder

  def decode_unabsorbed_insulin(<<>>, records), do: records |> Enum.reverse
  def decode_unabsorbed_insulin(<<amount::8, age_lower_bits::8, _::2, age_higher_bits::2, _::4, tail::binary>>, records) do
    record = %{
      age: (age_higher_bits <<< 8) + age_lower_bits,
      amount: amount / 40.0
    }
    decode_unabsorbed_insulin(tail, [record | records])
  end
end
