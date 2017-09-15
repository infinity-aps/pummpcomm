defmodule Pummpcomm.History.DailyTotal523 do
   @moduledoc """
  `Utilities` > `Daily Totals` for Minimed 523
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  def event_type, do: :daily_total_523

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `Utilties` > `Daily Totals` for Minimed 515 for day starting on `timestamp`
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode daily totals
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.DailyTotal
end
