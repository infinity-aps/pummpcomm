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
  import Decocare.History.AlarmPump
  import Decocare.History.ResultDailyTotal
  import Decocare.History.ChangeBasalProfilePattern
  import Decocare.History.ChangeBasalProfile
  import Decocare.History.CalBGForPH
  import Decocare.History.AlarmSensor
  import Decocare.History.ClearAlarm
  import Decocare.History.SelectBasalProfile
  import Decocare.History.TempBasal
  import Decocare.History.ChangeParadigmLinkID
  import Decocare.History.TempBasalDuration
  import Decocare.History.ChangeTime
  import Decocare.History.NewTime
  import Decocare.History.LowBattery
  import Decocare.History.Battery
  import Decocare.History.SetAutoOff
  import Decocare.History.PumpSuspend
  import Decocare.History.PumpResume
  import Decocare.History.PumpRewind
  import Decocare.History.ChangeChildBlockEnable
  import Decocare.History.ChangeMaxBolus
  import Decocare.History.EnableDisableRemote
  import Decocare.History.ChangeMaxBasal
  import Decocare.History.EnableBolusWizard
  import Decocare.History.BGReceived
  import Decocare.History.ChangeBolusWizardSetup
  import Decocare.History.ChangeSensorSetup2
  import Decocare.History.RestoreMystery51
  import Decocare.History.RestoreMystery52
  import Decocare.History.RestoreMystery54
  import Decocare.History.RestoreMystery55
  import Decocare.History.ChangeSensorRateOfChangeAlertSetup
  import Decocare.History.ChangeSensorAlarmSilenceConfig
  import Decocare.History.ChangeBolusScrollStepSize
  import Decocare.History.BolusWizardSetup
  import Decocare.History.BolusWizardEstimate
  import Decocare.History.UnabsorbedInsulin
  import Decocare.History.ChangeVariableBolus
  import Decocare.History.ChangeAudioBolus
  import Decocare.History.ChangeBGReminderEnable
  import Decocare.History.ChangeAlarmClockEnable
  import Decocare.History.ChangeTempBasalType
  import Decocare.History.ChangeAlarmNotifyMode
  import Decocare.History.ChangeTimeDisplay
  import Decocare.History.ChangeReservoirWarningTime
  import Decocare.History.ChangeBolusReminderEnable
  import Decocare.History.DailyTotal522
  import Decocare.History.DailyTotal523
  import Decocare.History.ChangeCarbUnits
  import Decocare.History.BasalProfileStart
  import Decocare.History.ChangeWatchdogEnable
  import Decocare.History.ChangeOtherDeviceID
  import Decocare.History.DeleteOtherDeviceID
  import Decocare.History.ChangeCaptureEventEnable

  def decode(page, pump_model) do
    case Crc16.check_crc_16(page) do
      {:ok, _} -> {:ok, page |> Crc16.page_data |> decode_page(pump_options(pump_model)) |> Enum.reverse}
      other    -> other
    end
  end

  defp pump_options(pump_model) do
    %{
      large_format: PumpModel.large_format?(pump_model),
      strokes_per_unit: PumpModel.strokes_per_unit(pump_model),
      supports_low_suspend: PumpModel.supports_low_suspend?(pump_model)
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

  def decode_page(<<0x06, data::binary-size(8), tail::binary>>, pump_options, events) do
    event = {:alarm_pump, decode_alarm_pump(data) | %{ raw: <<0x06>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x07, data::binary-size(6), tail::binary>>, pump_options = %{large_format: false}, events) do
    event = {:result_daily_total, decode_result_daily_total(data) | %{ raw: <<0x07>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x07, data::binary-size(9), tail::binary>>, pump_options = %{large_format: true}, events) do
    event = {:result_daily_total, decode_result_daily_total(data) | %{ raw: <<0x07>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x08, data::binary-size(151), tail::binary>>, pump_options, events) do
    event = {:change_basal_profile_pattern, decode_change_basal_profile_pattern(data) | %{ raw: <<0x08>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x09, data::binary-size(151), tail::binary>>, pump_options, events) do
    event = {:change_basal_profile, decode_change_basal_profile(data) | %{ raw: <<0x09>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x0A, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:cal_bg_for_ph, decode_cal_bg_for_ph(data) | %{ raw: <<0x0A>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x0B, data::binary-size(7), tail::binary>>, pump_options, events) do
    event = {:alarm_sensor, decode_alarm_sensor(data) | %{ raw: <<0x0B>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x0C, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:clear_alarm, decode_clear_alarm(data) | %{ raw: <<0x0C>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x14, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:select_basal_profile, decode_select_basal_profile(data) | %{ raw: <<0x14>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


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

  def decode_page(<<0x1B, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:set_auto_off, decode_set_auto_off(data) | %{ raw: <<0x1B>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


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

  def decode_page(<<0x23, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_child_block_enable, decode_change_child_block_enable(data) | %{ raw: <<0x23>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


  def decode_page(<<0x24, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_max_bolus, decode_change_max_bolus(data) | %{ raw: <<0x24>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


  def decode_page(<<0x26, data::binary-size(20), tail::binary>>, pump_options, events) do
    event = {:enable_disable_remote, decode_enable_disable_remote(data) | %{ raw: <<0x26>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x2C, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_max_basal, decode_change_max_basal(data) | %{ raw: <<0x2C>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


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

  def decode_page(<<0x3C, data::binary-size(20), tail::binary>>, pump_options, events) do
    event = {:change_paradigm_link_id, decode_change_paradigm_link_id(data) | %{ raw: <<0x3C>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


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

  def decode_page(<<0x50, data::binary-size(36), tail::binary>>, pump_options = %{ supports_low_suspend: false }, events) do
    event = {:change_sensor_setup_2, decode_change_sensor_setup_2(data) | %{ raw: <<0x50>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x50, data::binary-size(40), tail::binary>>, pump_options = %{ supports_low_suspend: true }, events) do
    event = {:change_sensor_setup_2, decode_change_sensor_setup_2(data) | %{ raw: <<0x50>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x51, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:restore_mystery_51, decode_restore_mystery_51(data) | %{ raw: <<0x51>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x52, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:restore_mystery_52, decode_restore_mystery_52(data) | %{ raw: <<0x52>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x53, data::binary-size(7), tail::binary>>, pump_options, events) do
    event = {:change_sensor_alarm_silence_config, decode_change_sensor_alarm_silence_config(data) | %{ raw: <<0x53>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x54, data::binary-size(63), tail::binary>>, pump_options, events) do
    event = {:restore_mystery_54, decode_restore_mystery_54(data) | %{ raw: <<0x54>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x55, data::binary-size(54), tail::binary>>, pump_options, events) do
    event = {:restore_mystery_55, decode_restore_mystery_55(data) | %{ raw: <<0x55>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x56, data::binary-size(11), tail::binary>>, pump_options, events) do
    event = {:change_sensor_rate_of_change_alert_setup, decode_change_sensor_rate_of_change_alert_setup(data) | %{ raw: <<0x56>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

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

  def decode_page(<<0x5E, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_variable_bolus, decode_change_variable_bolus(data) | %{ raw: <<0x5E>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


  def decode_page(<<0x5F, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_audio_bolus, decode_change_audio_bolus(data) | %{ raw: <<0x5F>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x60, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_bg_reminder_enable, decode_change_bg_reminder_enable(data) | %{ raw: <<0x60>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


  def decode_page(<<0x61, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_alarm_clock_enable, decode_change_alarm_clock_enable(data) | %{ raw: <<0x61>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x62, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_temp_basal_type, decode_change_temp_basal_type(data) | %{ raw: <<0x62>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x63, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_alarm_notify_mode, decode_change_alarm_notify_mode(data) | %{ raw: <<0x63>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


  def decode_page(<<0x64, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_time_display, decode_change_time_display(data) | %{ raw: <<0x64>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x65, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_reservoir_warning_time, decode_change_reservoir_warning_time(data) | %{ raw: <<0x65>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


  def decode_page(<<0x66, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_bolus_reminder_enable, decode_change_bolus_reminder_enable(data) | %{ raw: <<0x66>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

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

  def decode_page(<<0x6F, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_carb_units, decode_change_carb_units(data) | %{ raw: <<0x6F>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x7B, data::binary-size(9), tail::binary>>, pump_options, events) do
    event = {:basal_profile_start, decode_basal_profile_start(data) | %{ raw: <<0x7B>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x7C, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_watchdog_enable, decode_change_watchdog_enable(data) | %{ raw: <<0x7C>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x7D, data::binary-size(36), tail::binary>>, pump_options, events) do
    event = {:change_other_device_id, decode_change_other_device_id(data) | %{ raw: <<0x7D>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  @change_watchdog_marriage_profile         0x81

  def decode_page(<<0x82, data::binary-size(11), tail::binary>>, pump_options, events) do
    event = {:delete_other_device_id, decode_delete_other_device_id(data) | %{ raw: <<0x82>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end


  def decode_page(<<0x83, data::binary-size(6), tail::binary>>, pump_options, events) do
    event = {:change_capture_event_enable, decode_change_capture_event_enable(data) | %{ raw: <<0x83>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end
end
