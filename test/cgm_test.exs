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

  test "correctly identifies relative timestamp events" do
    {:ok, cgm_page} = Base.decode16("1028B6140801CE6E")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:data_end, %{timestamp: _}} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies sensor data" do
    {:ok, cgm_page} = Base.decode16("1028B614081A6D34")
    {:ok, decoded_events} = Cgm.decode(cgm_page)
    assert {:sensor_glucose_value, %{timestamp: _, sgv: 52}} = Enum.at(decoded_events, 1)
  end
end
