defmodule Decocare.History.DeleteAlarmClockTime do
  alias Decocare.DateDecoder

  def decode_delete_alarm_clock_time(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
