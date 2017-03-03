defmodule Decocare.History.OtherMarker do
  alias Decocare.DateDecoder

  def decode_other_marker(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
