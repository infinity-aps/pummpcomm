defmodule Decocare.History.RestoreMystery55 do
  def event_type, do: :restore_mystery_55
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
