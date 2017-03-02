defmodule Decocare.History.ChangeReservoirWarningTime do
  alias Decocare.DateDecoder

  def decode_change_reservoir_warning_time(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
