defmodule Pummpcomm.History.EnableDisableRemoteTest do
  use ExUnit.Case

  test "Enable/Disable Remote" do
    {:ok, history_page}=Base.decode16("260150120C050F2706764D00000028000000000000")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    expected_event_info = %{
      timestamp: ~N[2015-04-05 12:18:16],
      raw: history_page
    }
    assert {:enable_disable_remote, ^expected_event_info} = Enum.at(decoded_events, 0)
  end
end
