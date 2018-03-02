defmodule Pummpcomm.History.ChangeMaxBasal do
  @moduledoc """
  When the max allowed basal is changed
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the max allowed basal is changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new max basal
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
