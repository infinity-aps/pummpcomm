defmodule Pummpcomm.History.CalBGForPHTest do
  use ExUnit.Case

  test "Cal BG For PH - 1" do
    {:ok, history_page} = Base.decode16("0AD90183346D11")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:cal_bg_for_ph, %{amount: 217, timestamp: ~N[2017-02-13 20:03:01], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

 test "Cal BG For PH - 2" do
    {:ok, history_page} = Base.decode16("0A6B2B82210E11")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:cal_bg_for_ph, %{amount: 107, timestamp: ~N[2017-02-14 01:02:43], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

  test "Cal BG For PH Middle Amount Bit" do
    {:ok, history_page} = Base.decode16("0AD90183346D91")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:cal_bg_for_ph, %{amount: 473, timestamp: ~N[2017-02-13 20:03:01], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

  test "Cal BG For PH High Amount Bit" do
    {:ok, history_page} = Base.decode16("0AD90183B46D11")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:cal_bg_for_ph, %{amount: 729, timestamp: ~N[2017-02-13 20:03:01], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
