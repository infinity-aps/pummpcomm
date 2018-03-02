defmodule Pummpcomm.History.SelectBasalProfile do
  @moduledoc """
  When the basal profile was switched when using Basal Profile Patterns
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the basal profile was switched when using Basal Profile Patterns
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode which profile was selected
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
