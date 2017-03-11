defmodule Pummpcomm.History.InsulinMarker do
  use Bitwise
  alias Pummpcomm.DateDecoder

  def decode(<<amount_low_bits::8, timestamp::binary-size(5), amount_high_bits::2, _::6>>, _) do
    %{
      amount: ((amount_high_bits <<< 8) + amount_low_bits) / 10.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
