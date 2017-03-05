defmodule Decocare.History.ChangeParadigmLinkID do
  defdelegate decode(body, pump_options), to: Decocare.History.StandardEvent
end
