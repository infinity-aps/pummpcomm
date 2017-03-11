defmodule Pummpcomm.History.DailyTotal do
  alias Pummpcomm.DateDecoder

  def decode(<<timestamp::binary-size(2), _::binary>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end
end
