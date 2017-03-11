defmodule Pummpcomm.History.ResultDailyTotalTest do
  use ExUnit.Case

  test "Result Daily Total - Smaller" do
    {:ok, history_page} = Base.decode16("07000007782D11")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{large_format: false})
    assert {:result_daily_total, %{strokes: 1912, units: 47.8, timestamp: ~N[2017-02-14 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

  test "Result Daily Total - Larger" do
    {:ok, history_page} = Base.decode16("0700000000378F000000")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{large_format: true})
    assert {:result_daily_total, %{strokes: 0, units: 0.0, timestamp: ~N[2015-03-24 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
