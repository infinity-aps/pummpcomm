defmodule Pummpcomm.History.ChangeAlarmClockEnableTest do
  use ExUnit.Case

  test "Change Alarm Clock Enable" do
    {:ok, history_page} = Base.decode16("61000040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_alarm_clock_enable, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
