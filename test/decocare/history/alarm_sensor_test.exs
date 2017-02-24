defmodule Decocare.History.AlarmSensorTest do
  use ExUnit.Case

  test "Alarm Sensor - Meter BG Now" do
    {:ok, history_page} = Base.decode16("0B6800008034AD11")
    decoded_events = Decocare.History.decode_page(history_page, %{})
    assert {:alarm_sensor, %{alarm_type: "Meter BG Now", timestamp: ~N[2017-02-13 20:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

  test "Alarm Sensor - Glucose High" do
    {:ok, history_page} = Base.decode16("0B65DD218E34AD11")
    decoded_events = Decocare.History.decode_page(history_page, %{})
    expected_event_info = %{
      alarm_type: "High Glucose",
      amount: 221,
      timestamp: ~N[2017-02-13 20:14:33],
      raw: history_page
    }
    assert {:alarm_sensor, ^expected_event_info} = Enum.at(decoded_events, 0)
  end
end
