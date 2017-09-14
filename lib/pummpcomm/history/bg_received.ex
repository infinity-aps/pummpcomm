defmodule Pummpcomm.History.BGReceived do
  @moduledoc """
  A blood glucose received from a meter.
  """

  use Bitwise
  alias Pummpcomm.{BloodGlucose, DateDecoder}

  # Types

  @typedoc """
  ID of meter linked to pump
  """
  @type meter_link_id :: binary

  # Functions

  @doc """
  Blood glucose `amount` received from `meter_link_id` at `timestamp`.
  """
  @spec decode(<<_ :: 72>>, Pummpcomm.PumpModel.pump_options) :: %{
                                                                   amount: BloodGlucose.blood_glucose,
                                                                   meter_link_id: meter_link_id,
                                                                   timestamp: NaiveDateTime.t
                                                                 }
  def decode(body, pump_options)
  def decode(<<amount::8, timestamp::binary-size(5), meter_link_id::binary-size(3)>>, _) do
    <<_::size(16), amount_low_bits::size(3), _::size(21)>> = timestamp
    %{
      amount: (amount <<< 3) + amount_low_bits,
      meter_link_id: Base.encode16(meter_link_id),
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
