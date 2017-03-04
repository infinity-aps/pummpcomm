defmodule Decocare.History.RestoreMystery55 do
  alias Decocare.DateDecoder

  def event_type, do: :restore_mystery_55

  def decode(<<_::8, timestamp::binary-size(5), _::binary-size(48)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
