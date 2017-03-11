defmodule Pummpcomm.History.ClearAlarmTest do
  use ExUnit.Case

  test "Clear Alarm" do
    {:ok, history_page} = Base.decode16("0C3D760F0C050F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:clear_alarm, %{timestamp: ~N[2015-04-05 12:15:54], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
