defmodule Decocare.History.ChangeAlarmClockEnable do
  alias Decocare.DateDecoder

  def decode_change_alarm_clock_enable(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
