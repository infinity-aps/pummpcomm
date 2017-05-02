defmodule Pummpcomm.History.ChangeMaxBasalTest do
  use ExUnit.Case

  test "Change Max Basal" do
    {:ok, history_page} = Base.decode16("2C500040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_max_basal, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
