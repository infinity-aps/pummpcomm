defmodule Pummpcomm.History.DailyTotal do
  @moduledoc """
  `Utilities` > `Daily Totals`
  """

  alias Pummpcomm.DateDecoder

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `Utilties` > `Daily Totals` for day starting on `timestamp`
  """
  @impl Pummpcomm.History.Decoder
  # TODO decode daily totals
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{timestamp: NaiveDateTime.t()}
  def decode(body, pump_options)

  def decode(<<timestamp::binary-size(2), _::binary>>, _) do
    %{
      timestamp: timestamp |> DateDecoder.decode_history_timestamp() |> Timex.shift(days: 1)
    }
  end
end
