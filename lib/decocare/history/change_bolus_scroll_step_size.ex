defmodule Decocare.History.ChangeBolusScrollStepSize do
  use Bitwise
  alias Decocare.DateDecoder

  def decode_change_bolus_scroll_step_size(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
