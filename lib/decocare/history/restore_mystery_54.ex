defmodule Decocare.History.RestoreMystery54 do
  alias Decocare.DateDecoder

  def decode_restore_mystery_54(<<_::8, timestamp::binary-size(5), _::binary-size(57)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
