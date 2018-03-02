defmodule Pummpcomm.History.AlarmClockReminder do
  @moduledoc """
  A `Pummpcomm.History.StandardEvent` tied to an alarm set in `MAIN MENU` > `Utilities` > `Alarm Clock`.
  """

  @behaviour Pummpcomm.History.Decoder

  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
