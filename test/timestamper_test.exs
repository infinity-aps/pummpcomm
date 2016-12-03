defmodule TimestamperTest do
  use ExUnit.Case

  doctest Timestamper

  test "correctly assigns relative timestamps" do
    {:ok, cgm_page} = Base.decode16("1028B6140813131313133F77")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    {:ok, %{processed: processed}} = Timestamper.timestamp_events(decoded_events)
    assert {:nineteen_something, %{timestamp: ~N[2016-02-08 21:19:00]}} = Enum.at(processed, 5)
  end

  test "correctly identifies sensor data" do
    {:ok, cgm_page} = Base.decode16("1028B614081A6D34")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    {:ok, %{processed: processed}} = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_glucose_value, %{timestamp: _, sgv: 52}} = Enum.at(processed, 1)
  end

  test "correctly identifies data end" do
    {:ok, cgm_page} = Base.decode16("1028B6140801CE6E")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    {:ok, %{processed: processed}} = Timestamper.timestamp_events(decoded_events)
    assert {:data_end, %{timestamp: _}} = Enum.at(processed, 1)
  end

  test "correctly identifies sensor weak signal" do
    {:ok, cgm_page} = Base.decode16("1028B6140802FE0D")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    {:ok, %{processed: processed}} = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_weak_signal, %{timestamp: _}} = Enum.at(processed, 1)
  end

  test "correctly identifies sensor calibration" do
    {:ok, cgm_page} = Base.decode16("1028B61408010300037CE0")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    {:ok, %{processed: processed}} = Timestamper.timestamp_events(decoded_events)
    assert {:sensor_calibration, %{waiting: :waiting, timestamp: _}} = Enum.at(processed, 1)
    assert {:sensor_calibration, %{waiting: :meter_bg_now, timestamp: _}} = Enum.at(processed, 2)
  end

  test "correctly identifies 0x10 something" do
    {:ok, cgm_page} = Base.decode16("1028B614100144B4")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    {:ok, %{processed: processed}} = Timestamper.timestamp_events(decoded_events)
    assert {:ten_something, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(processed, 0)
    assert {:data_end, %{timestamp: ~N[2016-02-08 20:59:00]}} = Enum.at(processed, 1)
  end
end
