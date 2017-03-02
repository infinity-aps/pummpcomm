defmodule Decocare.History.SelectBasalProfile do
  alias Decocare.DateDecoder

  def decode_select_basal_profile(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
