defmodule Pummpcomm.History.RestoreMystery51 do
  def event_type, do: :restore_mystery_51
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
