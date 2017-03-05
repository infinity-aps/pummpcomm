defmodule Decocare.History.EnableDisableRemote do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
