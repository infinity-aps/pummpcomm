defmodule Decocare.History.ClearSettings do
  alias Decocare.DateDecoder

  def decode_clear_settings(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
