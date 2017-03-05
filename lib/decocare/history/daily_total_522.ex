defmodule Decocare.History.DailyTotal522 do
  alias Decocare.DateDecoder

  def event_type, do: :daily_total_522

  def decode(<<timestamp::binary-size(2), _::binary-size(41)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end
end
