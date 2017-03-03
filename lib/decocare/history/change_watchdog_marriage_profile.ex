defmodule Decocare.History.ChangeWatchdogMarriageProfile do
  alias Decocare.DateDecoder

  def decode_change_watchdog_marriage_profile(<<_::8, timestamp::binary-size(5), _::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
