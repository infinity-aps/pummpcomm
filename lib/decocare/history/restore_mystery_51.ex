defmodule Decocare.History.RestoreMystery51 do
  alias Decocare.DateDecoder

  def decode_restore_mystery_51(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
