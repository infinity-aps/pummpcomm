defmodule Pummpcomm.History.CalBGForPH do
  @moduledoc """
  Calibration blood glucose for pump history.
  """
  use Bitwise

  alias Pummpcomm.{BloodGlucose, DateDecoder}

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  Blood glucose `amount`
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{
                                                              amount: BloodGlucose.blood_glucose,
                                                              timestamp: NaiveDateTime.t
                                                            }
  def decode(body, pump_options)
  def decode(<<amount::8, timestamp::binary-size(5)>>, _) do
    <<_::size(16), amount_high_bit::size(1), _::size(15), amount_medium_bit::size(1), _::size(7)>> = timestamp
    %{
      amount: (amount_high_bit <<< 9) + (amount_medium_bit <<< 8) + amount,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
