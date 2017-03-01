defmodule Decocare.History.ChangeSensorRateOfChangeAlertSetup do
  alias Decocare.DateDecoder

  def decode_change_sensor_rate_of_change_alert_setup(<<_::8, timestamp::binary-size(5), _::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
