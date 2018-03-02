defmodule Pummpcomm.History.SaveSettings do
  @moduledoc """
  When settings were saved
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when settings were saved
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
