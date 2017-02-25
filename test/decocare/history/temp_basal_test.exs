defmodule Decocare.History.TempBasalTest do
  use ExUnit.Case

  test "Temp Basal with absolute rate type" do
    {:ok, history_page} = Base.decode16("33360C9A144D1100")
    decoded_events = Decocare.History.decode_page(history_page, %{})
    assert {:temp_basal, %{rate_type: :absolute, rate: 1.35, timestamp: ~N[2017-02-13 20:26:12], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

  test "Temp Basal with percent rate type" do
    {:ok, history_page} = Base.decode16("335A7B68111E0F08")
    decoded_events = Decocare.History.decode_page(history_page, %{})
    assert {:temp_basal, %{rate_type: :percent, rate: 90, timestamp: ~N[2015-05-30 17:40:59], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
