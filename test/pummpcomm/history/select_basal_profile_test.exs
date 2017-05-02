defmodule Pummpcomm.History.SelectBasalProfileTest do
  use ExUnit.Case

  test "Select Basal Profile" do
    {:ok, history_page} = Base.decode16("14000040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:select_basal_profile, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
