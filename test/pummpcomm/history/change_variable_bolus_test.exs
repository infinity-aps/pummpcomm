defmodule Pummpcomm.History.ChangeVariableBolusTest do
  use ExUnit.Case

  test "Change Variable Bolus" do
    {:ok, history_page} = Base.decode16("5E000040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_variable_bolus, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
