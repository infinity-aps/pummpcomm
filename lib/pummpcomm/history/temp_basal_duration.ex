defmodule Pummpcomm.History.TempBasalDuration do
  @moduledoc """
  How long a `Pummpcomm.History.TempBasal` was active.
  """

  alias Pummpcomm.DateDecoder

  @behaviour Pummpcomm.History.Decoder

  # Types

  # TODO determine units of `duration`
  @type duration :: non_neg_integer

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when `PummpComm.History.TempBasal` ended after `duration`.
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{duration: duration, timestamp: NaiveDateTime.t}
  def decode(body, pump_options)
  def decode(<<duration::8, timestamp::binary-size(5)>>, _) do
    %{
      duration: duration * 30,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
