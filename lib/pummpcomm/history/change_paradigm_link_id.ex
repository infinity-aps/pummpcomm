defmodule Pummpcomm.History.ChangeParadigmLinkID do
  @moduledoc """
  When Paradigm Link ID is changed
  """

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  When Paradigm Link ID is changed
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode new Paradigm Link ID
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  defdelegate decode(body, pump_options), to: Pummpcomm.History.StandardEvent
end
