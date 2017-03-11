defmodule Pummpcomm.History.LowBatteryTest do
  use ExUnit.Case

  test "Low Battery" do
    {:ok, history_page} = Base.decode16("190000C2081F0F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:low_battery, %{timestamp: ~N[2015-03-31 08:02:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
