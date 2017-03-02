defmodule Decocare.History.ClearAlarm do
  alias Decocare.DateDecoder

  def decode_clear_alarm(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
