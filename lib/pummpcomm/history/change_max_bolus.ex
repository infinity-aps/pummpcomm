defmodule Pummpcomm.History.ChangeMaxBolus do
  @moduledoc """
  When max allowed bolus was changed.
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when max allowed bolus was changed.
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new max bolus
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
