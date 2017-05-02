defmodule Pummpcomm.History.ExerciseMarkerTest do
  use ExUnit.Case

  # TODO capture this in real life
  test "Exercise Marker" do
    {:ok, history_page} = Base.decode16("4100722713040F00")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:exercise_marker, %{timestamp: ~N[2015-04-04 19:39:50], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
