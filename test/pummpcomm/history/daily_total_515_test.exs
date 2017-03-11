defmodule Pummpcomm.History.DailyTotal515Test do
  use ExUnit.Case

  # TODO capture in the wild
  test "Daily Total 515" do
    {:ok, history_page} = Base.decode16("6C2D110500AF85D9020000077803E434039430008203943002F05200A4120000000907020000")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{large_format: false})
    assert {:daily_total_515, %{timestamp: ~N[2017-02-14 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
