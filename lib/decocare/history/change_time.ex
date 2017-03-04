defmodule Decocare.History.ChangeTime do
  alias Decocare.DateDecoder

  def decode(<<_::8, timestamp::binary-size(5)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
