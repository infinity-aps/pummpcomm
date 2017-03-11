defmodule Pummpcomm.History.BolusNormal do
  alias Pummpcomm.DateDecoder

  def decode(<<programmed::8, amount::8, raw_duration::8, timestamp::binary-size(5)>>, %{strokes_per_unit: strokes_per_unit}) do
    duration = raw_duration * 30
    %{
      programmed: programmed / strokes_per_unit,
      amount: amount / strokes_per_unit,
      duration: duration,
      type: type_from_duration(duration),
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end

  def decode(<<programmed::16, amount::16, unabsorbed_insulin::16, raw_duration::8, timestamp::binary-size(5)>>, %{strokes_per_unit: strokes_per_unit}) do
    duration = raw_duration * 30
    %{
      programmed: programmed / strokes_per_unit,
      amount: amount / strokes_per_unit,
      duration: duration,
      unabsorbed_insulin: unabsorbed_insulin / strokes_per_unit,
      type: type_from_duration(duration),
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end

  defp type_from_duration(0), do: :normal
  defp type_from_duration(_), do: :square
end
