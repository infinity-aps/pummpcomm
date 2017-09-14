defmodule Pummpcomm.History.ChangeOtherDeviceID do
  @moduledoc """
  When Other Device ID is changed
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when Other Device ID is changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new device ID
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
