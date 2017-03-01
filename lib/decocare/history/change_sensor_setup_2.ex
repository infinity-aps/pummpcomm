defmodule Decocare.History.ChangeSensorSetup2 do
  alias Decocare.DateDecoder

  def decode_change_sensor_setup_2(<<_::8, timestamp::binary-size(5), _::binary-size(30)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end

  def decode_change_sensor_setup_2(<<_::8, timestamp::binary-size(5), _::binary-size(34)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
