defmodule Pummpcomm.History.ChangeBGReminderEnableTest do
  use ExUnit.Case

  test "Change BG Reminder Enable" do
    {:ok, history_page} = Base.decode16("60000040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_bg_reminder_enable, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
