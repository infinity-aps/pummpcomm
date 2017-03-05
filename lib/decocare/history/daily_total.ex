defmodule Decocare.History.DailyTotal do
  alias Decocare.DateDecoder

  def decode(<<timestamp::binary-size(2), _::binary>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp) |> Timex.shift(days: 1),
    }
  end
end
