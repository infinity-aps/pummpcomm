defmodule Pummpcomm.History.ChangeCarbUnitsTest do
  use ExUnit.Case

  test "Change Carb Units" do
    {:ok, history_page} = Base.decode16("6F010040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_carb_units, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
