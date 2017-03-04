defmodule Decocare.History.RestoreMystery52 do
  alias Decocare.DateDecoder

  def event_type, do: :restore_mystery_52

  def decode(<<_::8, timestamp::binary-size(5)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
