defmodule Pummpcomm.History.DeleteOtherDeviceID do
  @moduledoc """
  `Utilities` > `Connect Devices` > `Other Devices` > `On` > `Delete ID`
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when user did `Utilities` > `Connect Devices` > `Other Devices` > `On` > `Delete ID`
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode which Other Device ID entry was deleted
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
