defmodule Pummpcomm.History.PumpRewindTest do
  use ExUnit.Case

  test "Pump Rewind" do
    {:ok, history_page} = Base.decode16("21001DE813190F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:pump_rewind, %{timestamp: ~N[2015-03-25 19:40:29], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
