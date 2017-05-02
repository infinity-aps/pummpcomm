defmodule Pummpcomm.History.TempBasal do
  use Bitwise
  alias Pummpcomm.DateDecoder

  def decode(<<rate_low_bits::8, timestamp::binary-size(5), raw_rate_type::5, rate_high_bits::3>>, _) do
    %{
      rate_type: rate_type(raw_rate_type),
      rate: rate(rate_type(raw_rate_type), rate_high_bits, rate_low_bits),
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  defp rate_type(0), do: :absolute
  defp rate_type(_), do: :percent

  defp rate(:absolute, rate_high_bits, rate_low_bits), do: ((rate_high_bits <<< 8) + rate_low_bits) / 40.0
  defp rate(:percent, _, rate_low_bits), do: rate_low_bits
end
