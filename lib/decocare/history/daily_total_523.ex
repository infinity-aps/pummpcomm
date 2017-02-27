defmodule Decocare.History.DailyTotal523 do
  use Bitwise
  alias Decocare.DateDecoder

  def decode_daily_total_523(<<timestamp::binary-size(2), _::binary-size(49)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end
end
