defmodule Pummpcomm.History.ChangeChildBlockEnable do
  @moduledoc """
  When the Child Block to lock out the controls is enabled/disabled
  """
  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the Child Block to lock out the controls is enabled/disabled
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode enable/disable
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
