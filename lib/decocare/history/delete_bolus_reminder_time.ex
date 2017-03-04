defmodule Decocare.History.DeleteBolusReminderTime do
  alias Decocare.DateDecoder

  def decode(<<_::8, timestamp::binary-size(5), _::binary-size(2)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
