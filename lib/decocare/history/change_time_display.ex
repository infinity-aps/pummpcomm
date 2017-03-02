defmodule Decocare.History.ChangeTimeDisplay do
  alias Decocare.DateDecoder

  def decode_change_time_display(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
