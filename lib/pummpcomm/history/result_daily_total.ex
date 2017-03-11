defmodule Pummpcomm.History.ResultDailyTotal do
  alias Pummpcomm.DateDecoder

  def decode(<<_::16, strokes::16, timestamp::binary-size(2), _::binary>>, _) do
    %{
      strokes: strokes,
      units: strokes / 40.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1)
    }
  end
end
