defmodule Decocare.History.ChangeOtherDeviceIDTest do
  use ExUnit.Case

  test "Change Other Device ID" do
    {:ok, history_page} = Base.decode16("7D000040008108000000000000000000000000000000000000000000000000000000000000")
    decoded_events = Decocare.History.decode_page(history_page, %{})
    assert {:change_other_device_id, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
