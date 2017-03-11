defmodule Pummpcomm.History.DailyTotal522Test do
  use ExUnit.Case

  test "Daily Total 522" do
    {:ok, history_page} = Base.decode16("6D2D110500AF85D9020000077803E434039430008203943002F05200A41200000009070200005074324C1D02")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{large_format: false})
    assert {:daily_total_522, %{timestamp: ~N[2017-02-14 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
