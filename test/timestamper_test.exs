defmodule TimestamperTest do
  use ExUnit.Case

  doctest Timestamper

  test "correctly assigns relative timestamps" do
    {:ok, cgm_page} = Base.decode16("34451028B61408F4A3")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    timestamped_events = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2016-02-08 20:49:00]}} = Enum.at(timestamped_events, 0)
    assert {:sensor_glucose_value, %{sgv: 138, timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(timestamped_events, 1)
    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(timestamped_events, 2)
  end
end
