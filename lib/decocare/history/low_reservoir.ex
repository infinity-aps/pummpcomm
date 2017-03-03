defmodule Decocare.History.LowReservoir do
  alias Decocare.DateDecoder

  def decode_low_reservoir(<<raw_amount::8, timestamp::binary-size(5)>>) do
    %{
      amount: raw_amount / 10.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
