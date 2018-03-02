defmodule Pummpcomm.History.PumpResume do
  @moduledoc """
  When a `Pummpcomm.History.PumpSuspend` was resumed
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when a `Pummpcomm.History.PumpSuspend` was resumed.
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
