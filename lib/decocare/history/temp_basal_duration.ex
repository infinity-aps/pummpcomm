defmodule Decocare.History.TempBasalDuration do
  use Bitwise
  alias Decocare.DateDecoder

  def decode_temp_basal_duration(<<duration::8, timestamp::binary-size(5)>>) do
    %{
      duration: duration * 30,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
