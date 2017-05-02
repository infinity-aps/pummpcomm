defmodule Pummpcomm.History.ChangeReservoirWarningTimeTest do
  use ExUnit.Case

  test "Change Reservoir Warning Time" do
    {:ok, history_page} = Base.decode16("65500040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_reservoir_warning_time, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
