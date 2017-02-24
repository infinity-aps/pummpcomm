defmodule Decocare.History.BolusNormal do
  use Bitwise
  alias Decocare.DateDecoder, as: DateDecoder

  def decode_bolus_normal(<<programmed::8, amount::8, raw_duration::8, timestamp::binary-size(5)>>, strokes_per_unit) do
    duration = raw_duration * 30
    %{
      programmed: programmed / strokes_per_unit,
      amount: amount / strokes_per_unit,
      duration: duration,
      type: type_from_duration(duration),
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end

  defp type_from_duration(0), do: :normal
  defp type_from_duration(_), do: :square
end
