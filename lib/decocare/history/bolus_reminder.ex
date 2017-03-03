defmodule Decocare.History.BolusReminder do
  alias Decocare.DateDecoder

  def decode_bolus_reminder(<<_::8, timestamp::binary-size(5), _::binary-size(2)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
