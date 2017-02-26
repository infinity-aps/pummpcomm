defmodule Decocare.History.BGReceived do
  use Bitwise
  alias Decocare.DateDecoder, as: DateDecoder

  def decode_bg_received(<<amount::8, timestamp::binary-size(5), meter_link_id::binary-size(3)>>) do
    <<_::size(16), amount_low_bits::size(3), _::size(21)>> = timestamp
    %{
      amount: (amount <<< 3) + amount_low_bits,
      meter_link_id: Base.encode16(meter_link_id),
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
