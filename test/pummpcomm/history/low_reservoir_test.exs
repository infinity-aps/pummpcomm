defmodule Pummpcomm.History.LowReservoirTest do
  use ExUnit.Case

  test "Low Reservoir" do
    {:ok, history_page} = Base.decode16("34C8014F0A040F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:low_reservoir, %{amount: 20.0, timestamp: ~N[2015-01-04 10:15:01], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
