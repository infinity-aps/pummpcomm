defmodule Pummpcomm.History.OtherMarker do
  @moduledoc """
  A Captured Event that is not one of the following:
  * A manually entered blood glucose
  * `Pummpcomm.History.InsulinMarker`
  * `Pummpcomm.History.MealMarker`
  * `Pummpcomm.History.ExerciseMarker`
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when other type of event happened
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
