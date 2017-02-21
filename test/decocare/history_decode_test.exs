defmodule Decocare.HistoryTest do
  use ExUnit.Case

  doctest Decocare.History

  test "CalBGForPH" do
    {:ok, history_page} = Base.decode16("0AD90183346D116460")
    {:ok, decoded_events} = Decocare.History.decode(history_page)
    assert {:cal_bg_for_ph, %{amount: 217, timestamp: ~N[2017-02-13 20:03:01]}} = Enum.at(decoded_events, 0)
  end

  test "AlarmSensor" do
    {:ok, history_page} = Base.decode16("0B6800008034AD116A49")
    {:ok, decoded_events} = Decocare.History.decode(history_page)
    assert {:alarm_sensor, %{timestamp: ~N[2017-02-13 20:00:00]}} = Enum.at(decoded_events, 0)
  end
end
