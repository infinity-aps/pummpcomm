defmodule Pummpcomm.History.ChangeBolusReminderEnableTest do
  use ExUnit.Case

  test "Change Bolus Reminder Enable" do
    {:ok, history_page} = Base.decode16("66000040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_bolus_reminder_enable, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
