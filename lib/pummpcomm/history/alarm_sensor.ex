defmodule Pummpcomm.History.AlarmSensor do
  use Bitwise
  alias Pummpcomm.DateDecoder

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
  def decode(<<0x65, amount::8, timestamp::binary-size(5)>>, _) do
    decode(0x65, %{amount: amount(amount, timestamp)}, timestamp)
  end

  def decode(<<0x66, amount::8, timestamp::binary-size(5)>>, _) do
    decode(0x66, %{amount: amount(amount, timestamp)}, timestamp)
  end

  def decode(<<alarm_type::8, _::8, timestamp::binary-size(5)>>, _) do
    decode(alarm_type, %{}, timestamp)
  end

  def decode(alarm_type, alarm_params, timestamp) do
    Map.merge(%{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
      alarm_type: Map.get(@alarm_types, alarm_type, "Unknown")
    }, alarm_params)
  end

  defp amount(amount, timestamp) do
    <<_::32, high_bit::1, _::7>> = timestamp
    (high_bit <<< 8) + amount
  end
end
