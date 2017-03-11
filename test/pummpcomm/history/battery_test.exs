defmodule Pummpcomm.History.BatteryTest do
  use ExUnit.Case

  test "Battery" do
    {:ok, history_page} = Base.decode16("1A00722713040F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:battery, %{timestamp: ~N[2015-04-04 19:39:50], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
