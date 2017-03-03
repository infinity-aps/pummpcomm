defmodule Decocare.History.SaveSettings do
  alias Decocare.DateDecoder

  def decode_save_settings(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
