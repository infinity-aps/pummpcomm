defmodule Pummpcomm.History.SelfTest do
  @moduledoc """
  When user initiated or pump self-initiated a pump self-test.
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  When user initiated or pump self-initiated a pump self-test.
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{timestamp: NaiveDateTime.t}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
