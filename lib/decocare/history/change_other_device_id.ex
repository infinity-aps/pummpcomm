defmodule Decocare.History.ChangeOtherDeviceID do
  alias Decocare.DateDecoder

  def decode_change_other_device_id(<<_::8, timestamp::binary-size(5), _::binary-size(30)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
