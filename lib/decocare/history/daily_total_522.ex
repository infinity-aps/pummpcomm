defmodule Decocare.History.DailyTotal522 do
  use Bitwise
  alias Decocare.DateDecoder

  def decode_daily_total_522(<<timestamp::binary-size(2), _::binary-size(41)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end
end
