defmodule MapMerge do
  def a | b do
    Map.merge(a, b)
  end
end

defmodule Decocare.History do
  import MapMerge
  use Bitwise

  alias Decocare.Crc16
  alias Decocare.DateDecoder
  alias Decocare.PumpModel

  import Decocare.History.BolusNormal
  import Decocare.History.CalBGForPH
  import Decocare.History.AlarmSensor
  import Decocare.History.BGReceived
  import Decocare.History.BolusWizardEstimate
  import Decocare.History.UnabsorbedInsulin

  def decode(page, pump_model) do
    case Crc16.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc16.page_data |> decode_page(pump_options(pump_model)) |> Enum.reverse}
      other    -> other
    end
  end

  defp pump_options(pump_model) do
    %{
      large_format: PumpModel.large_format?(pump_model),
      strokes_per_unit: PumpModel.strokes_per_unit(pump_model)
    }
  end

  def decode_page(page_data, pump_options = %{}), do: decode_page(page_data, pump_options, [])
  def decode_page(<<>>, _, events), do: events

  def decode_page(<<0x01, data::binary-size(8), tail::binary>>, pump_options = %{large_format: false, strokes_per_unit: strokes_per_unit}, events) do
    event = {:bolus_normal, decode_bolus_normal(data, strokes_per_unit) | %{ raw: <<0x01>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  @prime                                    0x03
  @alarm_pump                               0x06
  @result_daily_total                       0x07
  @change_basal_profile_pattern             0x08
  @change_basal_profile                     0x09

  def decode_page(<<0x0A, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:cal_bg_for_ph, decode_cal_bg_for_ph(data) | %{ raw: <<0x0A>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x0B, data::binary-size(7), tail::binary>>, pump_options, events) do
    event = {:alarm_sensor, decode_alarm_sensor(data) | %{ raw: <<0x0B>> <> data }}
    decode_page(tail, pump_options, [event | events])
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

  def decode_page(<<0x3F, data::binary-size(9), tail::binary>>, pump_options, events) do
    event = {:bg_received, decode_bg_received(data) | %{ raw: <<0x3F>> <> data }}
    decode_page(tail, pump_options, [event | events])
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

  def decode_page(<<0x5B, data::binary-size(19), tail::binary>>, pump_options = %{large_format: false}, events) do
    event = {:bolus_wizard_estimate, decode_bolus_wizard_estimate(data) | %{ raw: <<0x5B>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x5C, length::8, tail::binary>>, pump_options = %{large_format: false}, events) do
    data_length = max((length - 2), 2)
    <<data::binary-size(data_length), tail::binary>> = tail
    event_info = %{
      data: decode_unabsorbed_insulin(data, []),
      raw: <<0x5C, length::8>> <> data
    }
    event = {:unabsorbed_insulin, event_info}
    decode_page(tail, pump_options, [event | events])
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
