defmodule Decocare.History.ChangeSensorSetup2 do
  alias Decocare.DateDecoder

  def event_type, do: :change_sensor_setup_2

  def decode(<<_::8, timestamp::binary-size(5), _::binary-size(30)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end

  def decode(<<_::8, timestamp::binary-size(5), _::binary-size(34)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
