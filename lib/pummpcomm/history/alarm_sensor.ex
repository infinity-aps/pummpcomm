defmodule Pummpcomm.History.AlarmSensor do
  @moduledoc """
  An alarm raised on the pump on behalf of the CGM.
  """

  use Bitwise
  alias Pummpcomm.{BloodGlucose, DateDecoder}

  @behaviour Pummpcomm.History.Decoder

  # CONSTANTS

  # TODO change to atom to match Pummpcomm.History.AlarmPump and because dialyzer can check for errors easier with atoms
  #   than String.t
  @alarm_types %{
    0x65 => "High Glucose",
    0x66 => "Low Glucose",
    0x68 => "Meter BG Now",
    0x69 => "Cal Reminder",
    0x6A => "Calibration Error",
    0x6B => "Sensor End",
    0x70 => "Weak Signal",
    0x71 => "Lost Sensor",
    0x73 => "Low Glucose Predicted"
  }

  # Types

  @typedoc """
  Type of alarm raised for the CGM.

  * `"High Glucose"` - CGM blood glucose exceeds sensor high glucose limit
  * `"Low Glucose"` - CGM blood glucose is below sensor low glucose limit
  * `"Meter BG Now"` - CGM needs a meter blood glucose NOW to contiue reporting CGM blood glucose.
  * `"Cal Reminder"` - CGM needs a meter blood glucose SOON to continue reporting CGM blood glucose.
  * `"Calibration Error"` - Meter blood glucose differed too much from expected blood glucose, so CGM value cannot be
      trusted.
  * `"Sensor End"` - Sensor has been in for 6 days.  Replace with new sensor.
  * `"Weak Signal"` - Signal to noise ratio is too low when pump is receiving data from CGM.  Move Pump closer to CGM.
  * `"Lost Sensor"` - Signal from CGM went noisier than `"Weak Signal"` and communication was completely lost.  Move CGM
       closer to pump, then go to `Sensor` > `Link to Sensor` > `Find Lost Sensor`.
  * `"Low Glucose Predicted"` - Due to rate of blood glucose change as measured by CGM, you are likely to hit
      `"Low Glucose"` soon.  Use meter blood glucose to confirm and eat something to correct if meter confirms CGM.
  """
  @type alarm_type :: String.t()

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) ::
          %{
            alarm_type: alarm_type,
            amount: BloodGlucose.blood_glucose(),
            timestamp: NaiveDateTime.t()
          }
          | %{
              alarm_type: alarm_type,
              timestamp: NaiveDateTime.t()
            }

  def decode(<<0x65, amount::8, timestamp::binary-size(5)>>, _) do
    decode(0x65, %{amount: amount(amount, timestamp)}, timestamp)
  end

  def decode(<<0x66, amount::8, timestamp::binary-size(5)>>, _) do
    decode(0x66, %{amount: amount(amount, timestamp)}, timestamp)
  end

  def decode(<<alarm_type::8, _::8, timestamp::binary-size(5)>>, _) do
    decode(alarm_type, %{}, timestamp)
  end

  ## Private Functions

  defp amount(amount, timestamp) do
    <<_::32, high_bit::1, _::7>> = timestamp
    (high_bit <<< 8) + amount
  end

  defp decode(alarm_type, alarm_params, timestamp) do
    Map.merge(
      %{
        timestamp: DateDecoder.decode_history_timestamp(timestamp),
        alarm_type: Map.get(@alarm_types, alarm_type, "Unknown")
      },
      alarm_params
    )
  end
end
