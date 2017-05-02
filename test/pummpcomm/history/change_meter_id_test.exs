defmodule Pummpcomm.History.ChangeMeterIDTest do
  use ExUnit.Case

  # TODO catch one of these in the wild
  test "Change Meter ID" do
    {:ok, history_page} = Base.decode16("3600722713040F0000000000000000000000000000")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_meter_id, %{timestamp: ~N[2015-04-04 19:39:50], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
