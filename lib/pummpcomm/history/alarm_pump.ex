defmodule Pummpcomm.History.AlarmPump do
  alias Pummpcomm.DateDecoder

  def decode(<<alarm_type::8, _::16, timestamp::binary-size(5)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
      alarm_type: alarm_type(alarm_type)
    }
  end

  def alarm_type(0x03), do: :battery_out_limit_exceeded
  def alarm_type(0x04), do: :no_delivery
  def alarm_type(0x05), do: :battery_depleted
  def alarm_type(0x06), do: :auto_off
  def alarm_type(0x10), do: :device_reset
  def alarm_type(0x3D), do: :reprogram_error
  def alarm_type(0x3E), do: :empty_reservoir
  def alarm_type(_), do: :unknown
end
