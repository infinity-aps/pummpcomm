defmodule Decocare.History.ChangeChildBlockEnable do
  alias Decocare.DateDecoder

  def decode_change_child_block_enable(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
