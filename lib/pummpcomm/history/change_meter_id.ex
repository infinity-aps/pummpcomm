defmodule Pummpcomm.History.ChangeMeterID do
  @moduledoc """
  When ID of meter was added or removed
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when ID of meter was added or removed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new meter ID
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
