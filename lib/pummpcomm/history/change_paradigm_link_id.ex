defmodule Pummpcomm.History.ChangeParadigmLinkID do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
