defmodule Pummpcomm.TimestamperTest do
  use ExUnit.Case
  alias Pummpcomm.Timestamper, as: Timestamper
  alias Pummpcomm.Cgm,         as: Cgm

  doctest Timestamper

  test "correctly assigns relative timestamps" do
    {:ok, cgm_page} = Base.decode16("34451028B61408F4A3")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    timestamped_events = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2016-02-08 20:49:00]}} = Enum.at(timestamped_events, 0)
    assert {:sensor_glucose_value, %{sgv: 138, timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(timestamped_events, 1)
    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(timestamped_events, 2)
  end

  test "it timestamps forward when there are only relative events since the last last_rf reference sensor timestamp" do
    {:ok, cgm_page} = Base.decode16("1008B614083445818B")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    timestamped_events = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00], event_type: :last_rf}} = Enum.at(timestamped_events, 0)
    assert {:sensor_glucose_value, %{sgv: 104, timestamp: ~N[2016-02-08 20:59:00]}} = Enum.at(timestamped_events, 1)
    assert {:sensor_glucose_value, %{sgv: 138, timestamp: ~N[2016-02-08 21:04:00]}} = Enum.at(timestamped_events, 2)
  end

  test "it does not timestamp forward when the most recent sensor timestamp is something other than rf" do
    {:ok, cgm_page} = Base.decode16("1048B614083445EB9B")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    timestamped_events = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00], event_type: :gap}} = Enum.at(timestamped_events, 0)
    assert {:sensor_glucose_value, %{sgv: 104, timestamp: nil}} = Enum.at(timestamped_events, 1)
    assert {:sensor_glucose_value, %{sgv: 138, timestamp: nil}} = Enum.at(timestamped_events, 2)
  end

  test "it does not timestamp forward when there's an intermediate non relative event since last sensor timestamp" do
    {:ok, cgm_page} = Base.decode16("1008B6140811457898")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    timestamped_events = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00], event_type: :last_rf}} = Enum.at(timestamped_events, 0)
    assert {:unknown, _} = Enum.at(timestamped_events, 1)
    assert {:sensor_glucose_value, %{sgv: 138, timestamp: nil}} = Enum.at(timestamped_events, 2)
  end
end
