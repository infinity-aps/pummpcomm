defmodule Pummpcomm.History.LowReservoir do
  alias Pummpcomm.DateDecoder

  def decode(<<raw_amount::8, timestamp::binary-size(5)>>, _) do
    %{
      amount: raw_amount / 10.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
