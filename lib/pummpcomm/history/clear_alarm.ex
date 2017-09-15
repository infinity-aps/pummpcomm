defmodule Pummpcomm.History.ClearAlarm do
  @moduledoc """
  When a previously raised alarm is cleared by the user
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when a previously raised alarm is cleared by the user
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode which alarm
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
