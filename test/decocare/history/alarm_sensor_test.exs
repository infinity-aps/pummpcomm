defmodule Decocare.History.AlarmSensorTest do
  use ExUnit.Case

  test "Alarm Sensor" do
    {:ok, history_page} = Base.decode16("0B6800008034AD11")
    decoded_events = Decocare.History.decode_page(history_page, %{})
    assert {:alarm_sensor, %{alarm_type: "Meter BG Now", timestamp: ~N[2017-02-13 20:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
