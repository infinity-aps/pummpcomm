defmodule Decocare.History.ChangeSensorAlarmSilenceConfig do
  alias Decocare.DateDecoder

  def decode_change_sensor_alarm_silence_config(<<_::8, timestamp::binary-size(5), _::8>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
