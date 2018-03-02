defmodule Pummpcomm.Session.Exchange.ReadBgTargets do
  @moduledoc """
  Reads blood glucose targets for throughout the day.
  """

  alias Pummpcomm.BloodGlucose
  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @mgdl 1
  @mmol 2

  @opcode 0x9F

  @targets_max_count 8

  # Functions

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read the target low and high blood glucose throughout the day.
  """
  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  @doc """
  Decodes `Pummpcomm.Session.Response.t` to `units` the blood glucose targets are in and the high and low target for
  each open interval starting at `start`.
  """
  @spec decode(Response.t()) :: {
          :ok,
          %{
            targets: [
              %{
                bg_high: BloodGlucose.blood_glucose(),
                bg_low: BloodGlucose.blood_glucose(),
                start: NaiveDateTime.t()
              }
            ],
            units: String.t()
          }
        }
  def decode(%Response{opcode: @opcode, data: <<units::8, targets::binary>>}) do
    {:ok,
     %{
       units: decode_units(units),
       targets: decode_targets(units, targets, [], @targets_max_count)
     }}
  end

  ## Private Functions

  defp basal_time(raw_time) do
    Timex.now()
    |> Timex.beginning_of_day()
    |> Timex.shift(minutes: 30 * raw_time)
    |> DateTime.to_time()
  end

  defp decode_bg(bg, @mgdl), do: bg
  defp decode_bg(bg, @mmol), do: bg / 10

  defp decode_targets(_, _, decoded_targets, 0), do: Enum.reverse(decoded_targets)

  defp decode_targets(_, <<0::8, _::binary>>, decoded_targets, _) when length(decoded_targets) > 0,
    do: Enum.reverse(decoded_targets)

  defp decode_targets(
         units,
         <<raw_start_time::8, bg_low::8, bg_high::8, rest::binary>>,
         decoded_targets,
         count
       ) do
    target = %{
      start: basal_time(raw_start_time),
      bg_low: decode_bg(bg_low, units),
      bg_high: decode_bg(bg_high, units)
    }

    decode_targets(units, rest, [target | decoded_targets], count - 1)
  end

  defp decode_units(@mgdl), do: "mg/dL"
  defp decode_units(@mmol), do: "mmol/L"
end
