defmodule Decocare.History.BolusNormalTest do
  use ExUnit.Case

  test "Bolus Normal" do
    {:ok, history_page} = Base.decode16("011D1D000785340D11")
    decoded_events = Decocare.History.decode_page(history_page, %{large_format: false, strokes_per_unit: 10})
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

  test "Bolus Square" do
    {:ok, history_page} = Base.decode16("011D1D010785340D11")
    decoded_events = Decocare.History.decode_page(history_page, %{large_format: false, strokes_per_unit: 10})
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
