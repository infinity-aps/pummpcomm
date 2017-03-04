defmodule Decocare.History.TempBasalDuration do
  use Bitwise
  alias Decocare.DateDecoder

  def decode(<<duration::8, timestamp::binary-size(5)>>, _) do
    %{
      duration: duration * 30,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
