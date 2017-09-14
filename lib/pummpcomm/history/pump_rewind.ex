defmodule Pummpcomm.History.PumpRewind do
  @moduledoc """
  When the pump screw was rewound to prepare for a new reservoir set.
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when the pump screw was rewound to prepare for a new reservoir set.
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
