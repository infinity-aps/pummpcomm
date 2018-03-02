defmodule Pummpcomm.History.ChangeTime do
  @moduledoc """
  When the pump's time is changed
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the pump's time is changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new time
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
