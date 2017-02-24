defmodule Decocare.History.BolusWizardEstimateTest do
  use ExUnit.Case

  test "Bolus Wizard Estimate" do
    {:ok, history_page} = Base.decode16("5BD90685140D11005006234B2400000007001D5A")
    decoded_events = Decocare.History.decode_page(history_page, %{ large_format: false })
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
end
