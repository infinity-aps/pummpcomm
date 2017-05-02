defmodule Pummpcomm.History.DeleteAlarmClockTimeTest do
  use ExUnit.Case

  # TODO capture in the wild
  test "Delete Alarm Clock Time" do
    {:ok, history_page} = Base.decode16("6A00722713040F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:delete_alarm_clock_time, %{timestamp: ~N[2015-04-04 19:39:50], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
