defmodule Decocare.History do
  use Bitwise

  alias Decocare.Crc16, as: Crc16
  alias Decocare.DateDecoder, as: DateDecoder

  @cal_bg_for_ph           0x0A
  @alarm_sensor            0x0B
  @bg_received             0x3F
  @bolus_wizard_estimate   0x5B

  def decode(page, large_format) do
    case Crc16.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc16.page_data |> decode_page(large_format) |> Enum.reverse}
      other    -> other
    end
  end

  def decode_page(page_data, large_format), do: decode_page(page_data, large_format, [])
  def decode_page(<<>>, _, events), do: events

  def decode_page(<<@cal_bg_for_ph, amount::8, timestamp::binary-size(5), tail::binary>>, large_format, events) do
    <<_::size(16), amount_high_bit::size(1), _::size(15), amount_medium_bit::size(1), _::size(7)>> = timestamp
    event_info = %{
      amount: (amount_high_bit <<< 9) + (amount_medium_bit <<< 8) + amount,
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
      raw: <<@cal_bg_for_ph::8, amount::8>> <> timestamp
    }
    event = {:cal_bg_for_ph, event_info}
    decode_page(tail, large_format, [event | events])
  end

  @alarm_types %{
    0x65 => "High Glucose",
    0x66 => "Low Glucose",
    0x68 => "Meter BG Now",
    0x69 => "Cal Reminder",
    0x6A => "Calibration Error",
    0x6B => "Sensor End",
    0x70 => "Weak Signal",
    0x71 => "Lost Sensor",
    0x73 => "Low Glucose Predicted"
  }
  def decode_page(<<@alarm_sensor::8, alarm_type::8, alarm_param::8, timestamp::binary-size(5), tail::binary>>, large_format, events) do
    event_info = %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
      alarm_type: Map.get(@alarm_types, alarm_type, "Unknown"),
      raw: <<@alarm_sensor::8, alarm_type::8, alarm_param::8>> <> timestamp
    }
    event = {:alarm_sensor, event_info}
    decode_page(tail, large_format, [event | events])
  end


  def decode_page(<<@bg_received, amount::8, timestamp::binary-size(5), meter_link_id::binary-size(3), tail::binary>>, large_format, events) do
    <<_::size(16), amount_low_bits::size(3), _::size(21)>> = timestamp
    event_info = %{
      amount: (amount <<< 3) + amount_low_bits,
      meter_link_id: Base.encode16(meter_link_id),
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
      raw: <<@bg_received::8, amount::8>> <> timestamp <> meter_link_id
    }
    event = {:bg_received, event_info}
    decode_page(tail, large_format, [event | events])
  end

  def decode_page(<<@bolus_wizard_estimate, data::binary-size(19), tail::binary>>, large_format = false, events) do
    <<bg_low_bits::8, timestamp::binary-size(5), carbohydrates::8, _::5, bg_high_bits::3, carb_ratio::8,
      insulin_sensitivity::8, bg_target_low::8, correction_estimate_low_bits::8, food_estimate::8,
      correction_estimate_high_bits::8, _::8, unabsorbed_insulin_total::8, _::8, bolus_estimate::8, bg_target_high::8>> = data

    event_info = %{
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
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
      raw: <<@bolus_wizard_estimate::8>> <> data
    }
    event = {:bolus_wizard_estimate, event_info}
    decode_page(tail, large_format, [event | events])
  end
end
