defmodule Pummpcomm.Monitor.BloodGlucoseMonitorTest do
  use ExUnit.Case

  alias Pummpcomm.Monitor.BloodGlucoseMonitor

  doctest Pummpcomm.Monitor.BloodGlucoseMonitor

  test "fetch most recent glucose reading" do
    {:ok, sensor_values} = BloodGlucoseMonitor.get_sensor_values(5)
    assert length(sensor_values) == 1
    assert %{sgv: 197} = Enum.at(sensor_values, 0)
  end

  test "fetch recent glucose readings across cgm pages" do
    {:ok, sensor_values} = BloodGlucoseMonitor.get_sensor_values(30)
    assert length(sensor_values) == 6
    assert %{sgv: 197} = Enum.at(sensor_values, 0)
    assert %{sgv: 192} = Enum.at(sensor_values, 1)
    assert %{sgv: 187} = Enum.at(sensor_values, 2)
    assert %{sgv: 182} = Enum.at(sensor_values, 3)
    assert %{sgv: 177} = Enum.at(sensor_values, 4)
    assert %{sgv: 172} = Enum.at(sensor_values, 5)
  end
end
