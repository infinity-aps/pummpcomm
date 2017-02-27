defmodule Decocare.History.PumpRewind do
  alias Decocare.DateDecoder

  def decode_pump_rewind(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
