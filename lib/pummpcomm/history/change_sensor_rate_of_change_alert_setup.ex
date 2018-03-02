defmodule Pummpcomm.History.ChangeSensorRateOfChangeAlertSetup do
  @moduledoc """
  When Fall Rate or Rise Rate alerts change
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when Fall Rate or Rise Rate alerts change
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new rate of change and whether it's or fall or rise
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
