defmodule Pummpcomm.History.SetAutoOffTest do
  use ExUnit.Case

  test "Set Auto Off" do
    {:ok, history_page} = Base.decode16("1B000040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:set_auto_off, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
