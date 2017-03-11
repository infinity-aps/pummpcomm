defmodule Pummpcomm.History.AlarmClockReminderTest do
  use ExUnit.Case

  test "Alarm Clock Reminder" do
    {:ok, history_page} = Base.decode16("35007771560B0D")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:alarm_clock_reminder, %{timestamp: ~N[2013-05-11 22:49:55], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
