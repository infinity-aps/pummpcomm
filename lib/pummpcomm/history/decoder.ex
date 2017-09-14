defmodule Pummpcomm.History.Decoder do
  @moduledoc """
  Decodes a page of history data
  """

  @callback decode(body :: binary, pump_options :: Pummpcomm.PumpModel.pump_options) :: map
end
