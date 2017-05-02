defmodule Pummpcomm.History.AlarmPumpTest do
  use ExUnit.Case

  test "Alarm Pump" do
    {:ok, history_page} = Base.decode16("063D0779730F2CE50F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:alarm_pump, %{alarm_type: :reprogram_error, timestamp: ~N[2015-04-05 12:15:51], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
