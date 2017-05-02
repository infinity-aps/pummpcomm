defmodule Pummpcomm.History.DailyTotal523Test do
  use ExUnit.Case

  test "Daily Total 523" do
    {:ok, history_page} = Base.decode16("6E368F05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:daily_total_523, %{timestamp: ~N[2015-03-23 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
