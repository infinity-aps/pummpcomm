defmodule Pummpcomm.History.DeleteAlarmClockTime do
  @moduledoc """
  `Utilities` > `Alarm Clock` > `Delete Alarm`
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when an alaram was deleted with `Utilities` > `Alarm Clock` > `Delete Alarm`
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode which alarm was deleted
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
