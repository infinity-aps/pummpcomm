defmodule Pummpcomm.History.EnableDisableRemote do
  @moduledoc """
  When the remote was enabled/disabled
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the remote was enabled/disabled
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode whether enabled or disabled
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
