defmodule Pummpcomm.History.LowReservoir do
  @moduledoc """
  Low Reservoir alarm
  """

  alias Pummpcomm.{DateDecoder, Insulin}

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when Low Reservoir alarm was raised with `amount` units left.
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{
          amount: Insulin.units(),
          timestamp: NaiveDateTime.t()
        }
  def decode(body, pump_options)

  def decode(<<raw_amount::8, timestamp::binary-size(5)>>, _) do
    %{
      amount: raw_amount / 10.0,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
