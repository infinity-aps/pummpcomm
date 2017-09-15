defmodule Pummpcomm.History.ChangeBolusScrollStepSize do
  @moduledoc """
  When the bolus scroll step size was changed.
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks
  @doc """
  `timestamp` when the bolus scroll step size was changed.
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode the new step size
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
