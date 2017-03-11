defmodule Pummpcomm.History.ChangeSensorRateOfChangeAlertSetupTest do
  use ExUnit.Case

  test "Change Sensor Rate Of Change Alert Setup" do
    {:ok, history_page} = Base.decode16("560000400081082828030F0B")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_sensor_rate_of_change_alert_setup, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
