defmodule Pummpcomm.History.Unknown3BTest do
  use ExUnit.Case

  test "Unknown 3B" do
    {:ok, history_page} = Base.decode16("3B00722713040F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:unknown_3b, %{timestamp: ~N[2015-04-04 19:39:50], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
