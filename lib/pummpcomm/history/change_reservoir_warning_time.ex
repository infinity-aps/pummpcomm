defmodule Pummpcomm.History.ChangeReservoirWarningTime do
  @moduledoc """
  When Low Reservoir Warning time is changed
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when Low Reservoir Warning time is changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new warning time
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
