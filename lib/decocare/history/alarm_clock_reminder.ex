defmodule Decocare.History.AlarmClockReminder do
  alias Decocare.DateDecoder

  def decode_alarm_clock_reminder(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
