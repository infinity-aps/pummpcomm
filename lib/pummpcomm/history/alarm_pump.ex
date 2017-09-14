defmodule Pummpcomm.History.AlarmPump do
  @moduledoc """
  An alarm raised by the pump about its internal operations.
  """

  alias Pummpcomm.DateDecoder

  @behaviour Pummpcomm.History.Decoder

  # Types

  @typedoc """
  An alarm raised by the pump about its internal operations.

  * `:battery_out_limit_exceeded` - Occurs if the battery has been out of the insulin pump for more than five (5)
     minutes or out of the CGM monitor for more than ten (10) minutes. Verify that the insulin pump/CGM Monitor time and
     date are correct.
  * `:no_delivery` - Pump detects a blockage or the reservoir is empty. Insulin delivery has stopped. Your pump is not
     broken, but it has detected that something is preventing insulin from being delivered.  This can happen if the
     infusion set need hits a bad spot in the rubber of the reservior or if the plugger rubber is overly sticky and the
     motor isn't strong enough to push the insulin out.  You can try removing the adapter from the infusin site and then
     giving a manual bolus or prime to see if insulin exits the port inside the ring.
  * `:battery_depleted` - The battery for the pump is depleted, but replace it within five (5) minutes or
    `:battery_out_limit_exceeded` alarm will be raised.  When the battery is depleted, the pump cannot receive wireless
    communication from meters and other devices.  If your blood glucose meter says it failed to send to the pump, check
    if the battery guage is empty on the pump or this alarm is raised.
  * `:auto_off` - `Pummpcomm.History.SetAutoOff` turned on auto-off in the past and the auto-off time period has elapsed
    without user interaction.
  * `:device_reset` - Your pump settings were cleared (`Pummpcomm.History.ClearSettings`), and the settings have not
    been reprogrammed.  Reprogram the settings to resume insulin delivery.
  * `:reprogram_error`
  * `:unknown` -  The monitor experienced an unknown hardware or software error.  Call support at 1-800-646-4633.
  """
  @type alarm_type :: :battery_out_limit_exceeded |
                      :no_delivery |
                      :battery_depleted |
                      :auto_off |
                      :device_reset |
                      :reprogram_error |
                      :empty_reservour |
                      :unknown

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  Decodes an alarm of `alarm_type` raised at `timestamp` by the pump.
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{alarm_type: alarm_type, timestamp: NaiveDateTime.t}
  def decode(body, pump_options)
  def decode(<<alarm_type::8, _::16, timestamp::binary-size(5)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
      alarm_type: alarm_type(alarm_type)
    }
  end

  ## Private Functions

  defp alarm_type(0x03), do: :battery_out_limit_exceeded
  defp alarm_type(0x04), do: :no_delivery
  defp alarm_type(0x05), do: :battery_depleted
  defp alarm_type(0x06), do: :auto_off
  defp alarm_type(0x10), do: :device_reset
  defp alarm_type(0x3D), do: :reprogram_error
  defp alarm_type(0x3E), do: :empty_reservoir
  defp alarm_type(_), do: :unknown
end
