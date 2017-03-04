defmodule MapMerge do
  def a | b do
    Map.merge(a, b)
  end
end

defmodule Decocare.HistoryDefinition do
  defmacro define_record(opcode, size_with_opcode, event_type) do
    decode_fn = "decode_#{event_type}" |> String.to_atom
    body_size = size_with_opcode - 1
    quote do
      def decode_page(<<unquote(opcode), data::binary-size(unquote(body_size)), tail::binary>>, pump_options, events) do
        event = {unquote(event_type), unquote(decode_fn)(data) | %{ raw: <<unquote(opcode)>> <> data }}
        decode_page(tail, pump_options, [event | events])
      end
    end
  end
end

defmodule Decocare.History do
  require Decocare.HistoryDefinition
  import MapMerge
  use Bitwise

  alias Decocare.Crc16
  alias Decocare.PumpModel

  import Decocare.HistoryDefinition

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
  import Decocare.History.LowReservoir
  import Decocare.History.AlarmClockReminder
  import Decocare.History.ChangeMeterID
  import Decocare.History.Unknown3B
  import Decocare.History.ChangeParadigmLinkID
  import Decocare.History.TempBasalDuration
  import Decocare.History.ChangeTime
  import Decocare.History.NewTime
  import Decocare.History.LowBattery
  import Decocare.History.Battery
  import Decocare.History.SetAutoOff
  import Decocare.History.PumpSuspend
  import Decocare.History.PumpResume
  import Decocare.History.SelfTest
  import Decocare.History.PumpRewind
  import Decocare.History.ClearSettings
  import Decocare.History.ChangeChildBlockEnable
  import Decocare.History.ChangeMaxBolus
  import Decocare.History.EnableDisableRemote
  import Decocare.History.ChangeMaxBasal
  import Decocare.History.EnableBolusWizard
  import Decocare.History.ChangeBGReminderOffset
  import Decocare.History.ChangeAlarmClockTime
  import Decocare.History.BGReceived
  import Decocare.History.MealMarker
  import Decocare.History.ExerciseMarker
  import Decocare.History.InsulinMarker
  import Decocare.History.OtherMarker
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
  import Decocare.History.SaveSettings
  import Decocare.History.ChangeVariableBolus
  import Decocare.History.ChangeAudioBolus
  import Decocare.History.ChangeBGReminderEnable
  import Decocare.History.ChangeAlarmClockEnable
  import Decocare.History.ChangeTempBasalType
  import Decocare.History.ChangeAlarmNotifyMode
  import Decocare.History.ChangeTimeDisplay
  import Decocare.History.ChangeReservoirWarningTime
  import Decocare.History.ChangeBolusReminderEnable
  import Decocare.History.ChangeBolusReminderTime
  import Decocare.History.DeleteBolusReminderTime
  import Decocare.History.BolusReminder
  import Decocare.History.DeleteAlarmClockTime
  import Decocare.History.DailyTotal515
  import Decocare.History.DailyTotal522
  import Decocare.History.DailyTotal523
  import Decocare.History.ChangeCarbUnits
  import Decocare.History.BasalProfileStart
  import Decocare.History.ChangeWatchdogEnable
  import Decocare.History.ChangeOtherDeviceID
  import Decocare.History.ChangeWatchdogMarriageProfile
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

  def decode_page(<<0x01, data::binary-size(12), tail::binary>>, pump_options = %{large_format: true, strokes_per_unit: strokes_per_unit}, events) do
    event = {:bolus_normal, decode_bolus_normal(data, strokes_per_unit) | %{ raw: <<0x01>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  define_record(0x03,  10, :prime)
  define_record(0x06,   9, :alarm_pump)

  def decode_page(<<0x07, data::binary-size(6), tail::binary>>, pump_options = %{large_format: false}, events) do
    event = {:result_daily_total, decode_result_daily_total(data) | %{ raw: <<0x07>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x07, data::binary-size(9), tail::binary>>, pump_options = %{large_format: true}, events) do
    event = {:result_daily_total, decode_result_daily_total(data) | %{ raw: <<0x07>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  define_record(0x08, 152, :change_basal_profile_pattern)
  define_record(0x09, 152, :change_basal_profile)
  define_record(0x0A,   7, :cal_bg_for_ph)
  define_record(0x0B,   8, :alarm_sensor)
  define_record(0x0C,   7, :clear_alarm)
  define_record(0x14,   7, :select_basal_profile)
  define_record(0x16,   7, :temp_basal_duration)
  define_record(0x17,   7, :change_time)
  define_record(0x18,   7, :new_time)
  define_record(0x19,   7, :low_battery)
  define_record(0x1A,   7, :battery)
  define_record(0x1B,   7, :set_auto_off)
  define_record(0x1E,   7, :pump_suspend)
  define_record(0x1F,   7, :pump_resume)
  define_record(0x20,   7, :self_test)
  define_record(0x21,   7, :pump_rewind)
  define_record(0x22,   7, :clear_settings)
  define_record(0x23,   7, :change_child_block_enable)
  define_record(0x24,   7, :change_max_bolus)
  define_record(0x26,  21, :enable_disable_remote)
  define_record(0x2C,   7, :change_max_basal)
  define_record(0x2D,   7, :enable_bolus_wizard)
  define_record(0x31,   7, :change_bg_reminder_offset)
  define_record(0x32,   7, :change_alarm_clock_time)
  define_record(0x33,   8, :temp_basal)
  define_record(0x34,   7, :low_reservoir)
  define_record(0x35,   7, :alarm_clock_reminder)
  define_record(0x36,  21, :change_meter_id)
  define_record(0x3B,   7, :unknown_3b)
  define_record(0x3C,  21, :change_paradigm_link_id)
  define_record(0x3F,  10, :bg_received)
  define_record(0x40,   9, :meal_marker)
  define_record(0x41,   8, :exercise_marker)
  define_record(0x42,   8, :insulin_marker)
  define_record(0x43,   7, :other_marker)
  define_record(0x4F,  39, :change_bolus_wizard_setup)

  def decode_page(<<0x50, data::binary-size(36), tail::binary>>, pump_options = %{ supports_low_suspend: false }, events) do
    event = {:change_sensor_setup_2, decode_change_sensor_setup_2(data) | %{ raw: <<0x50>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x50, data::binary-size(40), tail::binary>>, pump_options = %{ supports_low_suspend: true }, events) do
    event = {:change_sensor_setup_2, decode_change_sensor_setup_2(data) | %{ raw: <<0x50>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  define_record(0x51,   7, :restore_mystery_51)
  define_record(0x52,   7, :restore_mystery_52)
  define_record(0x53,   8, :change_sensor_alarm_silence_config)
  define_record(0x54,  64, :restore_mystery_54)
  define_record(0x55,  55, :restore_mystery_55)
  define_record(0x56,  12, :change_sensor_rate_of_change_alert_setup)
  define_record(0x57,   7, :change_bolus_scroll_step_size)
  define_record(0x5A, 144, :bolus_wizard_setup)

  def decode_page(<<0x5B, data::binary-size(19), tail::binary>>, pump_options = %{large_format: false}, events) do
    event = {:bolus_wizard_estimate, decode_bolus_wizard_estimate(data) | %{ raw: <<0x5B>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x5B, data::binary-size(21), tail::binary>>, pump_options = %{large_format: true}, events) do
    event = {:bolus_wizard_estimate, decode_bolus_wizard_estimate(data) | %{ raw: <<0x5B>> <> data }}
    decode_page(tail, pump_options, [event | events])
  end

  def decode_page(<<0x5C, length::8, tail::binary>>, pump_options, events) do
    data_length = max((length - 2), 2)
    <<data::binary-size(data_length), tail::binary>> = tail
    event_info = %{
      data: decode_unabsorbed_insulin(data, []),
      raw: <<0x5C, length::8>> <> data
    }
    event = {:unabsorbed_insulin, event_info}
    decode_page(tail, pump_options, [event | events])
  end

  define_record(0x5D,   7, :save_settings)
  define_record(0x5E,   7, :change_variable_bolus)
  define_record(0x5F,   7, :change_audio_bolus)
  define_record(0x60,   7, :change_bg_reminder_enable)
  define_record(0x61,   7, :change_alarm_clock_enable)
  define_record(0x62,   7, :change_temp_basal_type)
  define_record(0x63,   7, :change_alarm_notify_mode)
  define_record(0x64,   7, :change_time_display)
  define_record(0x65,   7, :change_reservoir_warning_time)
  define_record(0x66,   7, :change_bolus_reminder_enable)
  define_record(0x67,   9, :change_bolus_reminder_time)
  define_record(0x68,   9, :delete_bolus_reminder_time)
  define_record(0x69,   9, :bolus_reminder)
  define_record(0x6A,   7, :delete_alarm_clock_time)
  define_record(0x6C,  38, :daily_total_515)
  define_record(0x6D,  44, :daily_total_522)
  define_record(0x6E,  52, :daily_total_523)
  define_record(0x6F,   7, :change_carb_units)
  define_record(0x7B,  10, :basal_profile_start)
  define_record(0x7C,   7, :change_watchdog_enable)
  define_record(0x7D,  37, :change_other_device_id)
  define_record(0x81,  12, :change_watchdog_marriage_profile)
  define_record(0x82,  12, :delete_other_device_id)
  define_record(0x83,   7, :change_capture_event_enable)
end
