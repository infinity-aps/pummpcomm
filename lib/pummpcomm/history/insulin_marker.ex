defmodule Pummpcomm.History.InsulinMarker do
  @moduledoc """
  When user gave insulin without the pump
  """

  use Bitwise
  alias Pummpcomm.{DateDecoder, Insulin}

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when user gave `amount` units of insulin without the pump
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{amount: Insulin.units, timestamp: NaiveDateTime.t}
  def decode(body, pump_options)
  def decode(<<amount_low_bits::8, timestamp::binary-size(5), amount_high_bits::2, _::6>>, _) do
    %{
      amount: ((amount_high_bits <<< 8) + amount_low_bits) / 10.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
