defmodule Pummpcomm.History.ChangeAlarmClockTimeTest do
  use ExUnit.Case

  test "Change Alarm Clock Time" do
    {:ok, history_page} = Base.decode16("3200765D45070D")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_alarm_clock_time, %{timestamp: ~N[2013-05-07 05:29:54], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
