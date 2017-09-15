defmodule Pummpcomm.History.ChangeTimeDisplay do
  @moduledoc """
  When the time display is changed between 12 and 24 hours
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the time display is changed between 12 and 24 hours
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode whether 12 or 24 hours clock
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
