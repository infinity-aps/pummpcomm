defmodule Decocare.History.ChangeCarbUnits do
  alias Decocare.DateDecoder

  def decode_change_carb_units(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
