defmodule Pummpcomm.History.BolusWizardEstimateTest do
  use ExUnit.Case

  test "Bolus Wizard Estimate - Smaller" do
    {:ok, history_page} = Base.decode16("5BD90685140D11005006234B2400000007001D5A")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{ large_format: false })
    expected_event_info = %{
      bg: 217,
      bg_target_high: 90,
      bg_target_low: 75,
      bolus_estimate: 2.9,
      carbohydrates: 0,
      carb_ratio: 6,
      correction_estimate: 3.6,
      food_estimate: 0.0,
      insulin_sensitivity: 35,
      unabsorbed_insulin_total: 0.7,
      raw: history_page,
      timestamp: ~N[2017-02-13 20:05:06]
    }
    assert {:bolus_wizard_estimate, ^expected_event_info} = Enum.at(decoded_events, 0)
  end

  test "Bolus Wizard Estimate - Larger" do
    {:ok, history_page} = Base.decode16("5B0016E814790F5050003C285A000214000000021478")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{ large_format: true })
    expected_event_info = %{
      bg: 0,
      bg_target_high: 120,
      bg_target_low: 90,
      bolus_estimate: 13.3,
      carbohydrates: 80,
      carb_ratio: 6.0,
      correction_estimate: 0.0,
      food_estimate: 13.3,
      insulin_sensitivity: 40,
      unabsorbed_insulin_total: 0.0,
      raw: history_page,
      timestamp: ~N[2015-03-25 20:40:22]
    }
    assert {:bolus_wizard_estimate, ^expected_event_info} = Enum.at(decoded_events, 0)
  end
end
