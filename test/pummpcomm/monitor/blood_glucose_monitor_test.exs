defmodule Pummpcomm.Session.PumpTest do
  def get_current_cgm_page do
    {:ok, %{glucose: 32, isig: 32, page_number: 10}}
  end

  # returns 4 sensor glucose values starting at 3 minutes ago
  def read_cgm_page(10) do
    {:ok,
     Enum.map(3..0, fn(item) -> generate_sgv((item * 5) + 3) end)
    }
  end

  def read_cgm_page(9) do
    timestamp = {:sensor_timestamp, %{event_type: :page_end, raw: <<16, 40, 182, 20, 8>>, timestamp: time_for_minutes_back(23)}}
    {
      :ok,
      Enum.map(13..4, fn(item) -> generate_sgv((item * 5) + 3) end) ++ [timestamp]
    }
  end

  defp generate_sgv(minutes_back) do
    {:sensor_glucose_value,
     %{sgv: 200 - minutes_back, timestamp: time_for_minutes_back(minutes_back)}}
  end

  defp time_for_minutes_back(minutes_back) do
    Timex.local |> Timex.shift(minutes: -minutes_back) |> DateTime.to_naive
  end
end

defmodule Pummpcomm.Monitor.BloodGlucoseMonitorTest do
  use ExUnit.Case

  alias Pummpcomm.Monitor.BloodGlucoseMonitor

  doctest Pummpcomm.Monitor.BloodGlucoseMonitor

  setup do
    Application.put_env(:pummpcomm, :cgm, Pummpcomm.Session.PumpTest)
  end

  test "fetch most recent glucose reading" do
    {:ok, sensor_values} = BloodGlucoseMonitor.get_sensor_values(5)
    assert length(sensor_values) == 1
    assert %{sgv: 197} = Enum.at(sensor_values, 0) |> elem(1)
  end

  test "fetch recent glucose readings across cgm pages" do
    {:ok, sensor_values} = BloodGlucoseMonitor.get_sensor_values(30)
    assert length(sensor_values) == 6
    assert %{sgv: 197} = Enum.at(sensor_values, 0) |> elem(1)
    assert %{sgv: 192} = Enum.at(sensor_values, 1) |> elem(1)
    assert %{sgv: 187} = Enum.at(sensor_values, 2) |> elem(1)
    assert %{sgv: 182} = Enum.at(sensor_values, 3) |> elem(1)
    assert %{sgv: 177} = Enum.at(sensor_values, 4) |> elem(1)
    assert %{sgv: 172} = Enum.at(sensor_values, 5) |> elem(1)
  end
end
