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
    expected_timestamp = %{year: 2016, month: 2, day: 8, hour: 20, minute: 54}
    assert Enum.at(decoded_events, 0) == {:sensor_timestamp, timestamp: expected_timestamp}
  end
end
