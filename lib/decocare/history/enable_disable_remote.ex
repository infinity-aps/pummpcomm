defmodule Decocare.History.EnableDisableRemote do
  alias Decocare.DateDecoder

  def decode_enable_disable_remote(<<_::8, timestamp::binary-size(5), _::binary-size(14)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
