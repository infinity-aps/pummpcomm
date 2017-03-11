defmodule Pummpcomm.History.InsulinMarkerTest do
  use ExUnit.Case

  # TODO capture one of these in real life
  test "Insulin Marker" do
    {:ok, history_page} = Base.decode16("424C722713040FC0")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:insulin_marker, %{amount: 84.4, timestamp: ~N[2015-04-04 19:39:50], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
