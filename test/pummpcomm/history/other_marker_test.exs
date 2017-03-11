defmodule Pummpcomm.History.OtherMarkerTest do
  use ExUnit.Case

  # TODO capture this in real life
  test "Other Marker" do
    {:ok, history_page} = Base.decode16("4300722713040F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:other_marker, %{timestamp: ~N[2015-04-04 19:39:50], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
