defmodule Decocare.History.RestoreMystery54 do
  alias Decocare.DateDecoder

  def event_type, do: :restore_mystery_54

  def decode(<<_::8, timestamp::binary-size(5), _::binary-size(57)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
