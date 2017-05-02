defmodule Pummpcomm.History.NewTimeTest do
  use ExUnit.Case

  test "New Time" do
    {:ok, history_page} = Base.decode16("1800481D10450F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:new_time, %{timestamp: ~N[2015-04-05 16:29:08], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
