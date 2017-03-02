defmodule Decocare.History.Battery do
  alias Decocare.DateDecoder

  def decode_battery(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
