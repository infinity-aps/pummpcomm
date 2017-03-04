defmodule Decocare.History.ChangeBasalProfilePattern do
  alias Decocare.DateDecoder

  def decode(<<_::8, timestamp::binary-size(5), _::binary-size(145)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
