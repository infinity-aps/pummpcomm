defmodule Pummpcomm.History.TempBasalDuration do
  alias Pummpcomm.DateDecoder

  def decode(<<duration::8, timestamp::binary-size(5)>>, _) do
    %{
      duration: duration * 30,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
