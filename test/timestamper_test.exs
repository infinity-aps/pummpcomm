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

  test "it timestamps forward when there are only relative events since the last reference sensor timestamp" do
    {:ok, cgm_page} = Base.decode16("1008B614083445818B")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    timestamped_events = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00], event_type: :last_rf}} = Enum.at(timestamped_events, 0)
    assert {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2016-02-08 20:59:00]}} = Enum.at(timestamped_events, 1)
    assert {:sensor_glucose_value, %{sgv: 138, timestamp: ~N[2016-02-08 21:04:00]}} = Enum.at(timestamped_events, 2)
  end

  test "it does not timestamp forward when there's an intermediate non relative event since last sensor timestamp" do
    {:ok, cgm_page} = Base.decode16("1028B6140813452BF2")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    timestamped_events = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(timestamped_events, 0)
    assert {:nineteen_something, _} = Enum.at(timestamped_events, 1)
    assert {:sensor_glucose_value, %{sgv: 138, timestamp: nil}} = Enum.at(timestamped_events, 2)
  end
end
