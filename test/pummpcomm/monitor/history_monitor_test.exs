defmodule Pummpcomm.Monitor.HistoryMonitorTest do
  use ExUnit.Case

  alias Pummpcomm.Monitor.HistoryMonitor

  doctest Pummpcomm.Monitor.HistoryMonitor

  test "fetch most recent history page" do
    {:ok, history_values} = HistoryMonitor.get_pump_history(5, :local)
    assert length(history_values) == 2
    assert {:daily_total_523,    _} = Enum.at(history_values, 0)
    assert {:result_daily_total, _} = Enum.at(history_values, 1)
  end

  test "fetch recent history across history pages" do
    {:ok, history_values} = HistoryMonitor.get_pump_history(60, :local)
    assert length(history_values) == 4
    assert {:daily_total_523,    _} = Enum.at(history_values, 0)
    assert {:result_daily_total, _} = Enum.at(history_values, 1)
    assert {:bg_received,        _} = Enum.at(history_values, 2)
    assert {:alarm_sensor,       _} = Enum.at(history_values, 3)
  end
end
