defmodule Decocare.History.BGReceivedTest do
  use ExUnit.Case

  test "BG Received" do
    {:ok, history_page} = Base.decode16("3F1B0183346D11856250")
    decoded_events = Decocare.History.decode_page(history_page, %{})
    assert {:bg_received, %{amount: 217, meter_link_id: "856250", timestamp: ~N[2017-02-13 20:03:01], raw: ^history_page}} = Enum.at(decoded_events, 0)

    {:ok, history_page} = Base.decode16("3F1B0183D46D11856250")
    decoded_events = Decocare.History.decode_page(history_page, %{})
    assert {:bg_received, %{amount: 222, meter_link_id: "856250", timestamp: ~N[2017-02-13 20:03:01], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
