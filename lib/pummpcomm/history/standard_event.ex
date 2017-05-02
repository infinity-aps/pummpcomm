defmodule Pummpcomm.History.StandardEvent do
  alias Pummpcomm.DateDecoder

  def decode(<<_::8, timestamp::binary-size(5), _::binary>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
