defmodule CgmTest do
  use ExUnit.Case

  doctest Cgm

  setup do
    {:ok, cgm_page} = Base.decode16("1028B6140813131313133F77")
    {:ok, cgm_page: cgm_page}
  end

  test "decodes correct number of events", %{cgm_page: cgm_page} do
    assert {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert length(decoded_events) == 6
  end

  test "decodes correct event types", %{cgm_page: cgm_page} do
    assert {:ok, decoded_events} = Cgm.decode(cgm_page)
    event_types = decoded_events |> Enum.map(fn(event) -> elem(event, 0) end)
    assert event_types == [:sensor_timestamp,   :nineteen_something,
                           :nineteen_something, :nineteen_something,
                           :nineteen_something, :nineteen_something]
  end

  test "correctly assigns reference timestamps", %{cgm_page: cgm_page} do
    assert {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert Enum.at(decoded_events, 0) == {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00]}}
  end

  test "correctly assigns relative timestamps", %{cgm_page: cgm_page} do
    assert {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert Enum.at(decoded_events, 5) == {:nineteen_something, %{timestamp: ~N[2016-02-08 21:19:00]}}
  end

  test "correctly identifies data end" do
    {:ok, cgm_page} = Base.decode16("1028B6140801CE6E")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:data_end, %{timestamp: _}} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies sensor data" do
    {:ok, cgm_page} = Base.decode16("1028B614081A6D34")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:sensor_glucose_value, %{timestamp: _, sgv: 52}} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies sensor weak signal" do
    {:ok, cgm_page} = Base.decode16("1028B6140802FE0D")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:sensor_weak_signal, %{timestamp: _}} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies sensor calibration" do
    {:ok, cgm_page} = Base.decode16("1028B61408010300037CE0")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:sensor_calibration, %{waiting: :waiting, timestamp: _}} = Enum.at(decoded_events, 1)
    assert {:sensor_calibration, %{waiting: :meter_bg_now, timestamp: _}} = Enum.at(decoded_events, 2)
  end

  test "correctly identifies fokko-7" do
    {:ok, cgm_page} = Base.decode16("1028B61408FF0716AB")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:fokko7, _} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies sensor timestamp" do
    {:ok, cgm_page} = Base.decode16("1028B61408A53B")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies battery change" do
    {:ok, cgm_page} = Base.decode16("1028B6140A8579")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:battery_change, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies sensor status" do
    {:ok, cgm_page} = Base.decode16("1028B6140B9558")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:sensor_status, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies date time change" do
    {:ok, cgm_page} = Base.decode16("1028B6140CE5BF")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:datetime_change, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies sensor sync" do
    {:ok, cgm_page} = Base.decode16("1028B6140DF59E")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:sensor_sync, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies calibrate bg for glucose history" do
    {:ok, cgm_page} = Base.decode16("A08F135B4F0E7A69")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:cal_bg_for_gh, %{amount: 160, timestamp: ~N[2015-05-19 15:27:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies sensor calibration factor" do
    {:ok, cgm_page} = Base.decode16("8C120F13674F0F8EFC")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:sensor_calibration_factor, %{factor: 4.748, timestamp: ~N[2015-05-19 15:39:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies 0x10 something" do
    {:ok, cgm_page} = Base.decode16("1028B614100144B4")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:ten_something, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
    assert {:data_end, %{timestamp: ~N[2016-02-08 20:59:00]}} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies unknown opcodes" do
    {:ok, cgm_page} = Base.decode16("12D383")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:unknown, _} = Enum.at(decoded_events, 0)
  end

  test "slurps up zeros" do
    {:ok, cgm_page} = Base.decode16("000000CC9C")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert 0 == length(decoded_events)
  end
end
