defmodule Decocare.History.DailyTotal523 do
  alias Decocare.DateDecoder

  def event_type, do: :daily_total_523

  def decode(<<timestamp::binary-size(2), _::binary-size(49)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end
end
