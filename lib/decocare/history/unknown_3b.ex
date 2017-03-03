defmodule Decocare.History.Unknown3B do
  alias Decocare.DateDecoder

  def decode_unknown_3b(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
