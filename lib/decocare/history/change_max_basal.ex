defmodule Decocare.History.ChangeMaxBasal do
  alias Decocare.DateDecoder

  def decode_change_max_basal(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
