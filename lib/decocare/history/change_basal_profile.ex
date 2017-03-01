defmodule Decocare.History.ChangeBasalProfile do
  alias Decocare.DateDecoder

  def decode_change_basal_profile(<<_::8, timestamp::binary-size(5), _::binary-size(145)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
