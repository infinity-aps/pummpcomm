defmodule Pummpcomm.History.ResultDailyTotal do
  @moduledoc """
  The number of strokes and units given in a day
  """

  alias Pummpcomm.{DateDecoder, Insulin}

  @behaviour Pummpcomm.History.Decoder

  # Types

  @typedoc """
  The number of logic strokes of the stepper motor.  NOT the actual number of steps of the physical motor.

  There are 40 strokes per one `Insulin.units` regardless of the `Pummpcomm.PumpModel.pump_options` `strokes_per_unit`.
  """
  @type strokes :: non_neg_integer

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  The number of strokes and units given in a day
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) ::
          %{strokes: strokes, timestamp: NaiveDateTime.t, units: Insulin.units}
  def decode(body, pump_options)
  def decode(<<_::16, strokes::16, timestamp::binary-size(2), _::binary>>, _) do
    %{
      strokes: strokes,
      units: strokes / 40.0,
      timestamp: timestamp |> DateDecoder.decode_history_timestamp() |> Timex.shift(days: 1)
    }
  end
end
