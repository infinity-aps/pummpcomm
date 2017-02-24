defmodule Decocare.History.CalBGForPHTest do
  use ExUnit.Case

  test "Cal BG For PH" do
    {:ok, history_page} = Base.decode16("0AD90183346D11")
    decoded_events = Decocare.History.decode_page(history_page, false)
    assert {:cal_bg_for_ph, %{amount: 217, timestamp: ~N[2017-02-13 20:03:01], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

  test "Cal BG For PH Middle Amount Bit" do
    {:ok, history_page} = Base.decode16("0AD90183346D91")
    decoded_events = Decocare.History.decode_page(history_page, false)
    assert {:cal_bg_for_ph, %{amount: 473, timestamp: ~N[2017-02-13 20:03:01], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

  test "Cal BG For PH High Amount Bit" do
    {:ok, history_page} = Base.decode16("0AD90183B46D11")
    decoded_events = Decocare.History.decode_page(history_page, false)
    assert {:cal_bg_for_ph, %{amount: 729, timestamp: ~N[2017-02-13 20:03:01], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
