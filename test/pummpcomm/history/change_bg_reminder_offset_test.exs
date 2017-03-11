defmodule Pummpcomm.History.ChangeBGReminderOffsetTest do
  use ExUnit.Case

  # TODO find one of these in the wild
  test "Change BG Reminder Offset" do
    {:ok, history_page} = Base.decode16("3100722713040F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_bg_reminder_offset, %{timestamp: ~N[2015-04-04 19:39:50], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
