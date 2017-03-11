defmodule Pummpcomm.History.ChangeTimeTest do
  use ExUnit.Case

  test "Change Time" do
    {:ok, history_page} = Base.decode16("17005C2710450F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_time, %{timestamp: ~N[2015-04-05 16:39:28], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
