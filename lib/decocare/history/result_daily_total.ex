defmodule Decocare.History.ResultDailyTotal do
  use Bitwise
  alias Decocare.DateDecoder

  def decode_result_daily_total(<<_::16, strokes::16, timestamp::binary-size(2)>>) do
    %{
      strokes: strokes,
      units: strokes / 40.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end

  def decode_result_daily_total(<<_::16, strokes::16, timestamp::binary-size(2), _::binary-size(3)>>) do
    %{
      strokes: strokes,
      units: strokes / 40.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end
end
