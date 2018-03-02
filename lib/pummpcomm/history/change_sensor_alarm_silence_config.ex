defmodule Pummpcomm.History.ChangeSensorAlarmSilenceConfig do
  @moduledoc """
  When which alarms and how long the alarms are silenced is changed.
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  When which alarms and how long the alarms are silenced is changed.
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode which alarms and silence time
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
