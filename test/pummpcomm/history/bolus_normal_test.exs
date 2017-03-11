defmodule Pummpcomm.History.BolusNormalTest do
  use ExUnit.Case

  test "Bolus Normal - Smaller" do
    {:ok, history_page} = Base.decode16("011D1D000785340D11")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{large_format: false, strokes_per_unit: 10})
    expected_event_info = %{
      programmed: 2.9,
      amount: 2.9,
      duration: 0,
      type: :normal,
      timestamp: ~N[2017-02-13 20:05:07],
      raw: history_page
    }
    assert {:bolus_normal, ^expected_event_info} = Enum.at(decoded_events, 0)
  end

  test "Bolus Normal - Larger" do
    {:ok, history_page} = Base.decode16("01003C003C00000012E154790F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{large_format: true, strokes_per_unit: 40})
    expected_event_info = %{
      programmed: 1.5,
      amount: 1.5,
      duration: 0,
      type: :normal,
      unabsorbed_insulin: 0.0,
      timestamp: ~N[2015-03-25 20:33:18],
      raw: history_page
    }
    assert {:bolus_normal, ^expected_event_info} = Enum.at(decoded_events, 0)
  end

  test "Bolus Square" do
    {:ok, history_page} = Base.decode16("011D1D010785340D11")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{large_format: false, strokes_per_unit: 10})
    expected_event_info = %{
      programmed: 2.9,
      amount: 2.9,
      duration: 30,
      type: :square,
      timestamp: ~N[2017-02-13 20:05:07],
      raw: history_page
    }
    assert {:bolus_normal, ^expected_event_info} = Enum.at(decoded_events, 0)
  end
end
