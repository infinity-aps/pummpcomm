defmodule Pummpcomm.History.PumpSuspendTest do
  use ExUnit.Case

  test "Pump Suspend" do
    {:ok, history_page} = Base.decode16("1E0021B80D0E11")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:pump_suspend, %{timestamp: ~N[2017-02-14 13:56:33], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
