defmodule Decocare.HistoryDefinition do
  defmacro define_record(opcode, module, size_with_opcode, pump_matchers \\ %{}) do
    body_size = size_with_opcode - 1

    case pump_matchers do
      large_format: large_format ->
        quote do
          alias Decocare.History.unquote(module)
          def decode_page(<<unquote(opcode), body::binary-size(unquote(body_size)), tail::binary>>, pump_options = %{ large_format: unquote(large_format) }, events) do
            decode_record(unquote(module), <<unquote(opcode)::8>>, body, tail, pump_options, events)
          end
        end
      supports_low_suspend: supports_low_suspend ->
        quote do
          alias Decocare.History.unquote(module)
          def decode_page(<<unquote(opcode), body::binary-size(unquote(body_size)), tail::binary>>, pump_options = %{ supports_low_suspend: unquote(supports_low_suspend) }, events) do
            decode_record(unquote(module), <<unquote(opcode)::8>>, body, tail, pump_options, events)
          end
        end
      _ ->
        quote do
          alias Decocare.History.unquote(module)
          def decode_page(<<unquote(opcode), body::binary-size(unquote(body_size)), tail::binary>>, pump_options, events) do
            decode_record(unquote(module), <<unquote(opcode)::8>>, body, tail, pump_options, events)
          end
        end
    end
  end

  defmacro define_variable_record(opcode, module, length_fn) do
    quote do
      alias Decocare.History.unquote(module)
      def decode_page(<<unquote(opcode), length::8, rest::binary>>, pump_options, events) do
        remaining_bytes = unquote(length_fn).(length)
        <<body::binary-size(remaining_bytes), tail::binary>> = rest
        decode_record(unquote(module), <<unquote(opcode)::8, length::8>>, body, tail, pump_options, events)
      end
    end
  end
end

defmodule Decocare.History do
  require Decocare.HistoryDefinition
  use Bitwise

  alias Decocare.Crc16
  alias Decocare.PumpModel

  import Decocare.HistoryDefinition

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

  #                      op    name                              bytes  pump attributes
  define_record          0x01, BolusNormal,                          9, large_format: false
  define_record          0x01, BolusNormal,                         13, large_format: true
  define_record          0x03, Prime,                               10
  define_record          0x06, AlarmPump,                            9
  define_record          0x07, ResultDailyTotal,                     7, large_format: false
  define_record          0x07, ResultDailyTotal,                    10, large_format: true
  define_record          0x08, ChangeBasalProfilePattern,          152
  define_record          0x09, ChangeBasalProfile,                 152
  define_record          0x0A, CalBGForPH,                           7
  define_record          0x0B, AlarmSensor,                          8
  define_record          0x0C, ClearAlarm,                           7
  define_record          0x14, SelectBasalProfile,                   7
  define_record          0x16, TempBasalDuration,                    7
  define_record          0x17, ChangeTime,                           7
  define_record          0x18, NewTime,                              7
  define_record          0x19, LowBattery,                           7
  define_record          0x1A, Battery,                              7
  define_record          0x1B, SetAutoOff,                           7
  define_record          0x1E, PumpSuspend,                          7
  define_record          0x1F, PumpResume,                           7
  define_record          0x20, SelfTest,                             7
  define_record          0x21, PumpRewind,                           7
  define_record          0x22, ClearSettings,                        7
  define_record          0x23, ChangeChildBlockEnable,               7
  define_record          0x24, ChangeMaxBolus,                       7
  define_record          0x26, EnableDisableRemote,                 21
  define_record          0x2C, ChangeMaxBasal,                       7
  define_record          0x2D, EnableBolusWizard,                    7
  define_record          0x31, ChangeBGReminderOffset,               7
  define_record          0x32, ChangeAlarmClockTime,                 7
  define_record          0x33, TempBasal,                            8
  define_record          0x34, LowReservoir,                         7
  define_record          0x35, AlarmClockReminder,                   7
  define_record          0x36, ChangeMeterID,                       21
  define_record          0x3B, Unknown3B,                            7
  define_record          0x3C, ChangeParadigmLinkID,                21
  define_record          0x3F, BGReceived,                          10
  define_record          0x40, MealMarker,                           9
  define_record          0x41, ExerciseMarker,                       8
  define_record          0x42, InsulinMarker,                        8
  define_record          0x43, OtherMarker,                          7
  define_record          0x4F, ChangeBolusWizardSetup,              39
  define_record          0x50, ChangeSensorSetup2,                  37, supports_low_suspend: false
  define_record          0x50, ChangeSensorSetup2,                  41, supports_low_suspend: true
  define_record          0x51, RestoreMystery51,                     7
  define_record          0x52, RestoreMystery52,                     7
  define_record          0x53, ChangeSensorAlarmSilenceConfig,       8
  define_record          0x54, RestoreMystery54,                    64
  define_record          0x55, RestoreMystery55,                    55
  define_record          0x56, ChangeSensorRateOfChangeAlertSetup,  12
  define_record          0x57, ChangeBolusScrollStepSize,            7
  define_record          0x5A, BolusWizardSetup,                   144
  define_record          0x5B, BolusWizardEstimate,                 20, large_format: false
  define_record          0x5B, BolusWizardEstimate,                 22, large_format: true
  define_variable_record 0x5C, UnabsorbedInsulin,                       fn (length) -> max((length - 2), 2) end
  define_record          0x5D, SaveSettings,                         7
  define_record          0x5E, ChangeVariableBolus,                  7
  define_record          0x5F, ChangeAudioBolus,                     7
  define_record          0x60, ChangeBGReminderEnable,               7
  define_record          0x61, ChangeAlarmClockEnable,               7
  define_record          0x62, ChangeTempBasalType,                  7
  define_record          0x63, ChangeAlarmNotifyMode,                7
  define_record          0x64, ChangeTimeDisplay,                    7
  define_record          0x65, ChangeReservoirWarningTime,           7
  define_record          0x66, ChangeBolusReminderEnable,            7
  define_record          0x67, ChangeBolusReminderTime,              9
  define_record          0x68, DeleteBolusReminderTime,              9
  define_record          0x69, BolusReminder,                        9
  define_record          0x6A, DeleteAlarmClockTime,                 7
  define_record          0x6C, DailyTotal515,                       38
  define_record          0x6D, DailyTotal522,                       44
  define_record          0x6E, DailyTotal523,                       52
  define_record          0x6F, ChangeCarbUnits,                      7
  define_record          0x7B, BasalProfileStart,                   10
  define_record          0x7C, ChangeWatchdogEnable,                 7
  define_record          0x7D, ChangeOtherDeviceID,                 37
  define_record          0x81, ChangeWatchdogMarriageProfile,       12
  define_record          0x82, DeleteOtherDeviceID,                 12
  define_record          0x83, ChangeCaptureEventEnable,             7

  defp decode_record(module, head, body, tail, pump_options, events) do
    event_type = case apply(module, :"__info__", [:exports]) |> Keyword.get_values(:event_type) |> Enum.member?(0) do
                   true  -> apply(module, :event_type, [])
                   false -> module |> Module.split |> List.last |> Macro.underscore |> String.to_atom
                 end
    event_info = Map.put(apply(module, :decode, [body, pump_options]), :raw, head <> body)
    event = {event_type, event_info}
    decode_page(tail, pump_options, [event | events])
  end
end
