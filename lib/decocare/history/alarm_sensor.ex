defmodule Decocare.History.AlarmSensor do
  use Bitwise
  alias Decocare.DateDecoder, as: DateDecoder

  @alarm_types %{
    0x65 => "High Glucose",
    0x66 => "Low Glucose",
    0x68 => "Meter BG Now",
    0x69 => "Cal Reminder",
    0x6A => "Calibration Error",
    0x6B => "Sensor End",
    0x70 => "Weak Signal",
    0x71 => "Lost Sensor",
    0x73 => "Low Glucose Predicted"
  }
  def decode_alarm_sensor(<<alarm_type::8, alarm_param::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
      alarm_type: Map.get(@alarm_types, alarm_type, "Unknown")
    }
  end
end
