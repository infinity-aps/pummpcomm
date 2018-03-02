defmodule Pummpcomm.History.BolusNormal do
  @moduledoc """
  A normal bolus, entered by the user.
  """

  alias Pummpcomm.{DateDecoder, Insulin}

  @typedoc """
  The duration of the square wave bolus.  `0` when not a normal bolus.
  """
  # TODO determine units and document
  @type duration :: non_neg_integer

  @typedoc """
  Whether the bolus is delivered `:normal` (all at once) or as a `:square` wave over a `duration`.
  """
  @type type :: :normal | :square

  # Functions

  @doc """
  A `:normal` or `:square` bolus, entered manually by the user.
  """
  # TODO document difference between programmed and amount
  # TODO document all fields in type
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) ::
          %{
            programmed: Insulin.units(),
            amount: Insulin.units(),
            duration: duration,
            type: type,
            timestamp: NaiveDateTime.t()
          }
          | %{
              programmed: Insulin.units(),
              amount: Insulin.units(),
              duration: duration,
              unabsorbed_insulin: Insulin.units(),
              type: type,
              timestamp: NaiveDateTime.t()
            }

  def decode(body, pump_options)

  def decode(<<programmed::8, amount::8, raw_duration::8, timestamp::binary-size(5)>>, %{
        strokes_per_unit: strokes_per_unit
      }) do
    duration = raw_duration * 30

    %{
      programmed: programmed / strokes_per_unit,
      amount: amount / strokes_per_unit,
      duration: duration,
      type: type_from_duration(duration),
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  def decode(
        <<programmed::16, amount::16, unabsorbed_insulin::16, raw_duration::8,
          timestamp::binary-size(5)>>,
        %{strokes_per_unit: strokes_per_unit}
      ) do
    duration = raw_duration * 30

    %{
      programmed: programmed / strokes_per_unit,
      amount: amount / strokes_per_unit,
      duration: duration,
      unabsorbed_insulin: unabsorbed_insulin / strokes_per_unit,
      type: type_from_duration(duration),
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  ## Private Functions

  defp type_from_duration(0), do: :normal
  defp type_from_duration(_), do: :square
end
