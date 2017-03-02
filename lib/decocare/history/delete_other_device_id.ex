defmodule Decocare.History.DeleteOtherDeviceID do
  alias Decocare.DateDecoder

  def decode_delete_other_device_id(<<_::8, timestamp::binary-size(5), _::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
