defmodule Pummpcomm.History.ClearSettings do
  @moduledoc """
  The settings for the pump were cleared and reset to the factory defaults.  The pump will stop insulin delivery until
  reprogrammed.
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  The settings for the pump were cleared and reset to the factory defaults at `timestamp`.  The pump will stop insulin
  delivery until reprogrammed.
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
