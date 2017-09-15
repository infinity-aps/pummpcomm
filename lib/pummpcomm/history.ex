# Only a separate module to allow macro to be used in Pummpcomm.History
defmodule Pummpcomm.HistoryDefinition do
  @moduledoc false

  alias Pummpcomm.History

  defmacro define_record(opcode, module, size_fn) do
    quote do
      alias History.unquote(module)
      defp do_decode_records(<<unquote(opcode), body_and_tail::binary>>, pump_options, events) do
        body_length = calculate_length(unquote(size_fn), pump_options, body_and_tail)
        decode_record(unquote(module), unquote(opcode), body_length, body_and_tail, pump_options, events)
      end
    end
  end
end

defmodule Pummpcomm.History do
  @moduledoc """
  This module decodes a page of history from the pump into events and provides crc checking on the page.
  """

  require Pummpcomm.HistoryDefinition
  require Logger

  alias Pummpcomm.History.PumpModel
  alias Pummpcomm.Crc.Crc16
  alias Pummpcomm.PumpModel
  alias Pummpcomm.History.UnabsorbedInsulin

  import Pummpcomm.HistoryDefinition

  @spec decode(page :: binary, PumpModel.pump_model) :: {:ok, [any]} | {:error, String.t} | {:fail, String.t}
  def decode(page, pump_model) do
    case Crc16.check_crc_16(page) do
      {:ok, _} ->
        Logger.info fn ->
          "Decoding history page:\n#{Base.encode16(page)}"
        end
        {:ok, page |> Crc16.page_data |> decode_records(PumpModel.pump_options(pump_model)) |> Enum.reverse}
      other    ->
        other
    end
  end

  def decode_records(page_data, pump_options = %{}), do: do_decode_records(page_data, pump_options, [])

  ## Private Functions

  defp do_decode_records(<<>>, _, events), do: events

  #             op    name                                byte length
  define_record 0x00, NullByte,                           fixed_length(  1)
  define_record 0x01, BolusNormal,                        length_by_format(9, 13)
  define_record 0x03, Prime,                              fixed_length( 10)
  define_record 0x06, AlarmPump,                          fixed_length(  9)
  define_record 0x07, ResultDailyTotal,                   length_by_format(7, 10)
  define_record 0x08, ChangeBasalProfilePattern,          fixed_length(152)
  define_record 0x09, ChangeBasalProfile,                 fixed_length(152)
  define_record 0x0A, CalBGForPH,                         fixed_length(  7)
  define_record 0x0B, AlarmSensor,                        fixed_length(  8)
  define_record 0x0C, ClearAlarm,                         fixed_length(  7)
  define_record 0x14, SelectBasalProfile,                 fixed_length(  7)
  define_record 0x16, TempBasalDuration,                  fixed_length(  7)
  define_record 0x17, ChangeTime,                         fixed_length(  7)
  define_record 0x18, NewTime,                            fixed_length(  7)
  define_record 0x19, LowBattery,                         fixed_length(  7)
  define_record 0x1A, Battery,                            fixed_length(  7)
  define_record 0x1B, SetAutoOff,                         fixed_length(  7)
  define_record 0x1E, PumpSuspend,                        fixed_length(  7)
  define_record 0x1F, PumpResume,                         fixed_length(  7)
  define_record 0x20, SelfTest,                           fixed_length(  7)
  define_record 0x21, PumpRewind,                         fixed_length(  7)
  define_record 0x22, ClearSettings,                      fixed_length(  7)
  define_record 0x23, ChangeChildBlockEnable,             fixed_length(  7)
  define_record 0x24, ChangeMaxBolus,                     fixed_length(  7)
  define_record 0x26, EnableDisableRemote,                fixed_length( 21)
  define_record 0x2C, ChangeMaxBasal,                     fixed_length(  7)
  define_record 0x2D, EnableBolusWizard,                  fixed_length(  7)
  define_record 0x31, ChangeBGReminderOffset,             fixed_length(  7)
  define_record 0x32, ChangeAlarmClockTime,               fixed_length(  7)
  define_record 0x33, TempBasal,                          fixed_length(  8)
  define_record 0x34, LowReservoir,                       fixed_length(  7)
  define_record 0x35, AlarmClockReminder,                 fixed_length(  7)
  define_record 0x36, ChangeMeterID,                      fixed_length( 21)
  define_record 0x3B, Unknown3B,                          fixed_length(  7)
  define_record 0x3C, ChangeParadigmLinkID,               fixed_length( 21)
  define_record 0x3F, BGReceived,                         fixed_length( 10)
  define_record 0x40, MealMarker,                         fixed_length(  9)
  define_record 0x41, ExerciseMarker,                     fixed_length(  8)
  define_record 0x42, InsulinMarker,                      fixed_length(  8)
  define_record 0x43, OtherMarker,                        fixed_length(  7)
  define_record 0x4F, ChangeBolusWizardSetup,             fixed_length( 39)
  define_record 0x50, ChangeSensorSetup2,                 length_by_low_suspend(37, 41)
  define_record 0x51, RestoreMystery51,                   fixed_length(  7)
  define_record 0x52, RestoreMystery52,                   fixed_length(  7)
  define_record 0x53, ChangeSensorAlarmSilenceConfig,     fixed_length(  8)
  define_record 0x54, RestoreMystery54,                   fixed_length( 64)
  define_record 0x55, RestoreMystery55,                   fixed_length( 55)
  define_record 0x56, ChangeSensorRateOfChangeAlertSetup, fixed_length( 12)
  define_record 0x57, ChangeBolusScrollStepSize,          fixed_length(  7)
  define_record 0x5A, BolusWizardSetup,                   length_by_format(124, 144)
  define_record 0x5B, BolusWizardEstimate,                length_by_format(20, 22)
  define_record 0x5C, UnabsorbedInsulin,                  &UnabsorbedInsulin.event_length/1
  define_record 0x5D, SaveSettings,                       fixed_length(  7)
  define_record 0x5E, ChangeVariableBolus,                fixed_length(  7)
  define_record 0x5F, ChangeAudioBolus,                   fixed_length(  7)
  define_record 0x60, ChangeBGReminderEnable,             fixed_length(  7)
  define_record 0x61, ChangeAlarmClockEnable,             fixed_length(  7)
  define_record 0x62, ChangeTempBasalType,                fixed_length(  7)
  define_record 0x63, ChangeAlarmNotifyMode,              fixed_length(  7)
  define_record 0x64, ChangeTimeDisplay,                  fixed_length(  7)
  define_record 0x65, ChangeReservoirWarningTime,         fixed_length(  7)
  define_record 0x66, ChangeBolusReminderEnable,          fixed_length(  7)
  define_record 0x67, ChangeBolusReminderTime,            fixed_length(  9)
  define_record 0x68, DeleteBolusReminderTime,            fixed_length(  9)
  define_record 0x69, BolusReminder,                      fixed_length(  9)
  define_record 0x6A, DeleteAlarmClockTime,               fixed_length(  7)
  define_record 0x6C, DailyTotal515,                      fixed_length( 38)
  define_record 0x6D, DailyTotal522,                      fixed_length( 44)
  define_record 0x6E, DailyTotal523,                      fixed_length( 52)
  define_record 0x6F, ChangeCarbUnits,                    fixed_length(  7)
  define_record 0x7B, BasalProfileStart,                  fixed_length( 10)
  define_record 0x7C, ChangeWatchdogEnable,               fixed_length(  7)
  define_record 0x7D, ChangeOtherDeviceID,                fixed_length( 37)
  define_record 0x81, ChangeWatchdogMarriageProfile,      fixed_length( 12)
  define_record 0x82, DeleteOtherDeviceID,                fixed_length( 12)
  define_record 0x83, ChangeCaptureEventEnable,           fixed_length(  7)

  defp decode_record(module, head, body_length, body_and_tail, pump_options, events) do
    <<body::binary-size(body_length), tail::binary>> = body_and_tail
    event_info = module |> apply(:decode, [body, pump_options]) |> Map.put(:raw, <<head::8>> <> body)
    event = {event_type(module), event_info}
    do_decode_records(tail, pump_options, [event | events])
  end

  defp event_type(module) do
    case module |> apply(:"__info__", [:exports]) |> Keyword.get_values(:event_type) |> Enum.member?(0) do
      true  -> apply(module, :event_type, [])
      false -> module |> Module.split |> List.last |> Macro.underscore |> String.to_atom
    end
  end

  defp calculate_length(length_fn, pump_options, body_and_tail) do
    context = %{pump_options: pump_options, body_and_tail: body_and_tail}
    length_fn.(context) - 1
  end

  defp length_by_format(small_length, large_length) do
    fn (%{pump_options: %{large_format: large_format}}) ->
      case large_format do
        true -> large_length
        _    -> small_length
      end
    end
  end

  defp length_by_low_suspend(without_low_suspend_length, with_low_suspend_length) do
    fn (%{pump_options: %{supports_low_suspend: supports_low_suspend}}) ->
      case supports_low_suspend do
        true -> with_low_suspend_length
        _    -> without_low_suspend_length
      end
    end
  end

  defp fixed_length(length) do
    fn (_) -> length end
  end
end
