defmodule Decocare.History.Unknown3B do
  alias Decocare.DateDecoder

  def event_type, do: :unknown_3b

  def decode(<<_::8, timestamp::binary-size(5)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
