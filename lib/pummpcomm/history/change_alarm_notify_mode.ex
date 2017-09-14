defmodule Pummpcomm.History.ChangeAlarmNotifyMode do
  @moduledoc """
  When the `Alarm` > `Alert Type` was changed.
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the `Alarm` > `Alert Type` was changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode mode
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
