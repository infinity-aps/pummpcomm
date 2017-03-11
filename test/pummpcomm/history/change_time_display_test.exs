defmodule Pummpcomm.History.ChangeTimeDisplayTest do
  use ExUnit.Case

  test "Change Time Display" do
    {:ok, history_page} = Base.decode16("64001640000108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_time_display, %{timestamp: ~N[2008-01-01 00:00:22], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
