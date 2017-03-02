defmodule Decocare.History.SetAutoOff do
  alias Decocare.DateDecoder

  def decode_set_auto_off(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
