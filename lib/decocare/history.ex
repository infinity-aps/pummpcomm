defmodule MapMerge do
  def a | b do
    Map.merge(a, b)
  end
end

defmodule Decocare.History do
  import MapMerge
  use Bitwise

  alias Decocare.Crc16, as: Crc16
  alias Decocare.DateDecoder, as: DateDecoder

  def decode(page, large_format) do
    case Crc16.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc16.page_data |> decode_page(large_format) |> Enum.reverse}
      other    -> other
    end
  end

  def decode_page(page_data, large_format), do: decode_page(page_data, large_format, [])
  def decode_page(<<>>, _, events), do: events

  @bolus_normal                             0x01
  @prime                                    0x03
  @alarm_pump                               0x06
  @result_daily_total                       0x07
  @change_basal_profile_pattern             0x08
  @change_basal_profile                     0x09
  @cal_bg_for_ph                            0x0A
  def decode_page(<<@cal_bg_for_ph, data::binary-size(6), tail::binary>>, large_format, events) do
    raw = <<@cal_bg_for_ph::8>> <> data
    event = {:cal_bg_for_ph, decode_cal_bg_for_ph(data) | %{ raw: raw }}
    decode_page(tail, large_format, [event | events])
  end

  def decode_cal_bg_for_ph(data = <<amount::8, timestamp::binary-size(5)>>) do
    <<_::size(16), amount_high_bit::size(1), _::size(15), amount_medium_bit::size(1), _::size(7)>> = timestamp
    %{
      amount: (amount_high_bit <<< 9) + (amount_medium_bit <<< 8) + amount,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  @alarm_sensor                             0x0B
  def decode_page(<<@alarm_sensor::8, data::binary-size(7), tail::binary>>, large_format, events) do
    raw = <<@alarm_sensor>> <> data
    event = {:alarm_sensor, decode_alarm_sensor(data) | %{ raw: raw }}
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
  def decode_alarm_sensor(<<alarm_type::8, alarm_param::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
      alarm_type: Map.get(@alarm_types, alarm_type, "Unknown")
    }
  end

  @clear_alarm                              0x0C
  @select_basal_profile                     0x14
  @temp_basal_duration                      0x16
  @change_time                              0x17
  @new_time                                 0x18
  @journal_entry_pump_low_battery           0x19
  @battery                                  0x1A
  @set_auto_off                             0x1B
  @suspend                                  0x1E
  @resume                                   0x1F
  @selftest                                 0x20
  @rewind                                   0x21
  @clear_settings                           0x22
  @change_child_block_enable                0x23
  @change_max_bolus                         0x24
  @enable_disable_remote                    0x26
  @change_max_basal                         0x2C
  @enable_bolus_wizard                      0x2D
  @change_bg_reminder_offset                0x31
  @change_alarm_clock_time                  0x32
  @temp_basal                               0x33
  @journal_entry_pump_low_reservoir         0x34
  @alarm_clock_reminder                     0x35
  @change_meter_id                          0x36
  @questionable3b                           0x3B
  @change_paradigm_link_id                  0x3C
  @bg_received                              0x3F
  def decode_page(<<@bg_received, data::binary-size(9), tail::binary>>, large_format, events) do
    raw = <<@bg_received>> <> data
    event = {:bg_received, decode_bg_received(data) | %{ raw: raw }}
    decode_page(tail, large_format, [event | events])
  end

  def decode_bg_received(<<amount::8, timestamp::binary-size(5), meter_link_id::binary-size(3)>>) do
    <<_::size(16), amount_low_bits::size(3), _::size(21)>> = timestamp
    %{
      amount: (amount <<< 3) + amount_low_bits,
      meter_link_id: Base.encode16(meter_link_id),
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end

  @journal_entry_meal_marker                0x40
  @journal_entry_exercise_marker            0x41
  @journal_entry_insulin_marker             0x42
  @journal_entry_other_marker               0x43
  @change_bolus_wizard_setup                0x4F
  @change_sensor_setup2                     0x50
  @restore_mystery51                        0x51
  @restore_mystery52                        0x52
  @change_sensor_alarm_silence_config       0x53
  @restore_mystery54                        0x54
  @restore_mystery55                        0x55
  @change_sensor_rate_of_change_alert_setup 0x56
  @change_bolus_scroll_step_size            0x57
  @bolus_wizard_setup                       0x5A
  @bolus_wizard_estimate                    0x5B
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

  @unabsorbed_insulin                       0x5C
  def decode_page(<<@unabsorbed_insulin, length::8, tail::binary>>, large_format = false, events) do
    data_length = max((length - 2), 2)
    <<data::binary-size(data_length), tail::binary>> = tail
    event_info = %{
      data: decode_unabsorbed_insulin(data, []),
      raw: <<@unabsorbed_insulin::8, length::8>> <> data
    }
    event = {:unabsorbed_insulin, event_info}
    decode_page(tail, large_format, [event | events])
  end

  def decode_unabsorbed_insulin(<<>>, records), do: records |> Enum.reverse
  def decode_unabsorbed_insulin(<<amount::8, age_lower_bits::8, _::2, age_higher_bits::2, _::4, tail::binary>>, records) do
    record = %{
      age: (age_higher_bits <<< 8) + age_lower_bits,
      amount: amount / 40.0
    }
    decode_unabsorbed_insulin(tail, [record | records])
  end

  @save_settings                            0x5D
  @change_variable_bolus                    0x5E
  @change_audio_bolus                       0x5F
  @change_bg_reminder_enable                0x60
  @change_alarm_clock_enable                0x61
  @change_temp_basal_type                   0x62
  @change_alarm_notify_mode                 0x63
  @change_time_format                       0x64
  @change_reservoir_warning_time            0x65
  @change_bolus_reminder_enable             0x66
  @change_bolus_reminder_time               0x67
  @delete_bolus_reminder_time               0x68
  @bolus_reminder                           0x69
  @delete_alarm_clock_time                  0x6A
  @daily_total515                           0x6C
  @daily_total522                           0x6D
  @daily_total523                           0x6E
  @change_carb_units                        0x6F
  @basal_profile_start                      0x7B
  @change_watchdog_enable                   0x7C
  @change_other_device_id                   0x7D
  @change_watchdog_marriage_profile         0x81
  @delete_other_device_id                   0x82
  @change_capture_event_enable              0x83



end
