defmodule Pummpcomm.History.ChangeSensorAlarmSilenceConfigTest do
  use ExUnit.Case

  test "Change Sensor Alarm Silence Config" do
    {:ok, history_page} = Base.decode16("5300004000810800")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_sensor_alarm_silence_config, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
