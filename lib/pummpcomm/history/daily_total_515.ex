defmodule Pummpcomm.History.DailyTotal515 do
  def event_type, do: :daily_total_515
  defdelegate decode(body, pump_options), to: Pummpcomm.History.DailyTotal
end
