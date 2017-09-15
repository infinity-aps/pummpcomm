defmodule Pummpcomm.History.ChangeCarbUnits do
  @moduledoc """
  When carbohydrates units is switched between grams and exchanges
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when carbohydrates units is switched between grams and exchanges
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode whether grams or exchanges is selected
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
