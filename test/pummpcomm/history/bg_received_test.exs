defmodule Pummpcomm.History.BGReceivedTest do
  use ExUnit.Case

  test "BG Received - 1" do
    {:ok, history_page} = Base.decode16("3F1B0183346D11856250")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:bg_received, %{amount: 217, meter_link_id: "856250", timestamp: ~N[2017-02-13 20:03:01], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end

  test "BG Received - 2" do
    {:ok, history_page} = Base.decode16("3F0E1D8B646E11859551")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:bg_received, %{amount: 115, meter_link_id: "859551", timestamp: ~N[2017-02-14 04:11:29], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
