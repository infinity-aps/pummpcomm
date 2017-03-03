defmodule Decocare.History.ChangeBGReminderOffset do
  alias Decocare.DateDecoder

  def decode_change_bg_reminder_offset(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
