defmodule Decocare.History.DeleteBolusReminderTime do
  alias Decocare.DateDecoder

  def decode_delete_bolus_reminder_time(<<_::8, timestamp::binary-size(5), _::binary-size(2)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
