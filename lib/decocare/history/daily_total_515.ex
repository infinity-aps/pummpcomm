defmodule Decocare.History.DailyTotal515 do
  alias Decocare.DateDecoder

  def decode_daily_total_515(<<timestamp::binary-size(2), _::binary-size(35)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end
end
