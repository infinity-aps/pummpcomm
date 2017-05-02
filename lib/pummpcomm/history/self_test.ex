defmodule Pummpcomm.History.SelfTest do
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
