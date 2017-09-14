defmodule Pummpcomm.History.Battery do
  @moduledoc """
  When a low-battery alert was raised
  """

  @doc """

  """
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
