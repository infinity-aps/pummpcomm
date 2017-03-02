defmodule Decocare.History.ChangeBolusReminderEnable do
  alias Decocare.DateDecoder

  def decode_change_bolus_reminder_enable(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
