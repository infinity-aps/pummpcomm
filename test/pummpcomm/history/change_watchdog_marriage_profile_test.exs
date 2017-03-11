defmodule Pummpcomm.History.ChangeWatchdogMarriageProfileTest do
  use ExUnit.Case

  # TODO find one of these in the wild
  test "Change Watchdog Marriage Profile" do
    {:ok, history_page} = Base.decode16("810100400081080000000000")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_watchdog_marriage_profile, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
