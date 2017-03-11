defmodule Pummpcomm.History.BolusWizardEstimate do
  use Bitwise
  alias Pummpcomm.DateDecoder

  def decode(<<bg_low_bits::8, timestamp::binary-size(5), carbohydrates::8, _::6, bg_high_bits::2, carb_ratio::8,
    insulin_sensitivity::8, bg_target_low::8, correction_estimate_low_bits::8, food_estimate::8,
    correction_estimate_high_bits::8, _::8, unabsorbed_insulin_total::8, _::8, bolus_estimate::8, bg_target_high::8>>, _) do

    %{
      bg: (bg_high_bits <<< 8) + bg_low_bits,
      bg_target_high: bg_target_high,
      bg_target_low: bg_target_low,
      bolus_estimate: bolus_estimate / 10.0,
      carbohydrates: carbohydrates,
      carb_ratio: carb_ratio,
      correction_estimate: ((correction_estimate_high_bits <<< 8) + correction_estimate_low_bits) / 10.0,
      food_estimate: food_estimate / 10.0,
      insulin_sensitivity: insulin_sensitivity,
      unabsorbed_insulin_total: unabsorbed_insulin_total / 10.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  def decode(<<bg_low_bits::8, timestamp::binary-size(5), carbohydrates_low_bits::8, _::4, carbohydrates_high_bits::2,
    bg_high_bits::2, _::5, carb_ratio::11, insulin_sensitivity::8, bg_target_low::8, correction_estimate_low_bits::8, food_estimate::16,
    correction_estimate_high_bits::3, _::5, unabsorbed_insulin_total::16, bolus_estimate::16, bg_target_high::8>>, _) do

    %{
      bg: (bg_high_bits <<< 8) + bg_low_bits,
      bg_target_high: bg_target_high,
      bg_target_low: bg_target_low,
      bolus_estimate: bolus_estimate / 40.0,
      carbohydrates: (carbohydrates_high_bits <<< 8) + carbohydrates_low_bits,
      carb_ratio: carb_ratio / 10.0,
      correction_estimate: ((correction_estimate_high_bits <<< 8) + correction_estimate_low_bits) / 10.0,
      food_estimate: food_estimate / 40.0,
      insulin_sensitivity: insulin_sensitivity,
      unabsorbed_insulin_total: unabsorbed_insulin_total / 40.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
