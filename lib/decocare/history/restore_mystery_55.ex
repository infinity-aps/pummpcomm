defmodule Decocare.History.RestoreMystery55 do
  alias Decocare.DateDecoder

  def decode_restore_mystery_55(<<_::8, timestamp::binary-size(5), _::binary-size(48)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
