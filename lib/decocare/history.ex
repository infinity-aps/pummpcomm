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
  import Decocare.History.Prime
  import Decocare.History.ResultDailyTotal
  import Decocare.History.CalBGForPH
  import Decocare.History.AlarmSensor
  import Decocare.History.TempBasal
  import Decocare.History.TempBasalDuration
  import Decocare.History.ChangeTime
  import Decocare.History.NewTime
  import Decocare.History.LowBattery
  import Decocare.History.Battery
  import Decocare.History.PumpSuspend
  import Decocare.History.PumpResume
  import Decocare.History.PumpRewind
  import Decocare.History.EnableDisableRemote
  import Decocare.History.EnableBolusWizard
  import Decocare.History.BGReceived
  import Decocare.History.ChangeBolusWizardSetup
  import Decocare.History.ChangeBolusScrollStepSize
  import Decocare.History.BolusWizardSetup
  import Decocare.History.BolusWizardEstimate
  import Decocare.History.UnabsorbedInsulin
  import Decocare.History.ChangeAudioBolus
  import Decocare.History.DailyTotal522
  import Decocare.History.DailyTotal523
  import Decocare.History.BasalProfileStart

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

  def decode_page(<<0x00, tail::binary>>, pump_options, events) do
    event = {:null_byte, raw: <<0x00>>}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x01, data::binary-size(8), tail::binary>>, pump_options = %{large_format: false, strokes_per_unit: strokes_per_unit}, events) do
    event = {:bolus_normal, decode_bolus_normal(data, strokes_per_unit) | %{ raw: <<0x01>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x03, data::binary-size(9), tail::binary>>, pump_options, events) do
    event = {:prime, decode_prime(data) | %{ raw: <<0x03>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  @alarm_pump                               0x06

  def decode_page(<<0x07, data::binary-size(6), tail::binary>>, pump_options = %{large_format: false}, events) do
    event = {:result_daily_total, decode_result_daily_total(data) | %{ raw: <<0x07>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x07, data::binary-size(9), tail::binary>>, pump_options = %{large_format: true}, events) do
    event = {:result_daily_total, decode_result_daily_total(data) | %{ raw: <<0x07>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

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

  def decode_page(<<0x16, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:temp_basal_duration, decode_temp_basal_duration(data) | %{ raw: <<0x16>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x17, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_time, decode_change_time(data) | %{ raw: <<0x17>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x18, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:new_time, decode_new_time(data) | %{ raw: <<0x18>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x19, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:low_battery, decode_low_battery(data) | %{ raw: <<0x19>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x1A, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:battery, decode_battery(data) | %{ raw: <<0x1A>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  @set_auto_off                             0x1B

  def decode_page(<<0x1E, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:pump_suspend, decode_pump_suspend(data) | %{ raw: <<0x1E>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x1F, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:pump_resume, decode_pump_resume(data) | %{ raw: <<0x1F>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  @selftest                                 0x20

  def decode_page(<<0x21, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:pump_rewind, decode_pump_rewind(data) | %{ raw: <<0x21>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  @clear_settings                           0x22
  @change_child_block_enable                0x23
  @change_max_bolus                         0x24

  def decode_page(<<0x26, data::binary-size(20), tail::binary>>, pump_options, events) do
    event = {:enable_disable_remote, decode_enable_disable_remote(data) | %{ raw: <<0x26>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  @change_max_basal                         0x2C

  def decode_page(<<0x2D, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:enable_bolus_wizard, decode_enable_bolus_wizard(data) | %{ raw: <<0x2D>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  @change_bg_reminder_offset                0x31
  @change_alarm_clock_time                  0x32

  def decode_page(<<0x33, data::binary-size(7), tail::binary>>, pump_options, events) do
    event = {:temp_basal, decode_temp_basal(data) | %{ raw: <<0x33>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

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

  def decode_page(<<0x4F, data::binary-size(38), tail::binary>>, pump_options, events) do
    event = {:change_bolus_wizard_setup, decode_change_bolus_wizard_setup(data) | %{ raw: <<0x4F>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x50, data::binary-size(38), tail::binary>>, pump_options, events) do
    event = {:change_bolus_wizard_setup, decode_change_bolus_wizard_setup(data) | %{ raw: <<0x50>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end



  @restore_mystery51                        0x51
  @restore_mystery52                        0x52
  @change_sensor_alarm_silence_config       0x53
  @restore_mystery54                        0x54
  @restore_mystery55                        0x55
  @change_sensor_rate_of_change_alert_setup 0x56
  def decode_page(<<0x57, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_bolus_scroll_step_size, decode_change_bolus_scroll_step_size(data) | %{ raw: <<0x57>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x5A, data::binary-size(143), tail::binary>>, pump_options = %{large_format: true}, events) do
    event = {:bolus_wizard_setup, decode_bolus_wizard_setup(data) | %{ raw: <<0x5A>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

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

  def decode_page(<<0x5F, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_audio_bolus, decode_change_audio_bolus(data) | %{ raw: <<0x5F>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

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

  def decode_page(<<0x6D, data::binary-size(43), tail::binary>>, pump_options, events) do
    event = {:daily_total_522, decode_daily_total_522(data) | %{ raw: <<0x6D>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x6E, data::binary-size(51), tail::binary>>, pump_options, events) do
    event = {:daily_total_523, decode_daily_total_523(data) | %{ raw: <<0x6E>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  @change_carb_units                        0x6F

  def decode_page(<<0x7B, data::binary-size(9), tail::binary>>, pump_options, events) do
    event = {:basal_profile_start, decode_basal_profile_start(data) | %{ raw: <<0x7B>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


  @change_watchdog_enable                   0x7C
  @change_other_device_id                   0x7D
  @change_watchdog_marriage_profile         0x81
  @delete_other_device_id                   0x82
  @change_capture_event_enable              0x83
end
