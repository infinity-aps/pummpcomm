defmodule Decocare.History.DailyTotal515 do
  alias Decocare.DateDecoder

  def event_type, do: :daily_total_515

  def decode(<<timestamp::binary-size(2), _::binary-size(35)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end
end
