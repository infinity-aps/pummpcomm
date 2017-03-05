defmodule Decocare.History.DailyTotal515 do
  def event_type, do: :daily_total_515
  defdelegate decode(body, pump_options), to: Decocare.History.DailyTotal
end
