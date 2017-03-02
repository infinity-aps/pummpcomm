defmodule Decocare.History.ChangeWatchdogEnableTest do
  use ExUnit.Case

  test "Change Watchdog Enable" do
    {:ok, history_page} = Base.decode16("7C000040008108")
    decoded_events = Decocare.History.decode_page(history_page, %{})
    assert {:change_watchdog_enable, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
