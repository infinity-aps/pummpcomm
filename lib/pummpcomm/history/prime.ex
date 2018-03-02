defmodule Pummpcomm.History.Prime do
  @moduledoc """
  When a new cannula was primed
  """

  use Bitwise
  alias Pummpcomm.{Insulin, DateDecoder}

  @behaviour Pummpcomm.History.Decoder

  # Types

  @typedoc """
  * `:manual` - user entered a manual value for prime
  * `:fixed` - user used the fixed prime value of `0.5` or `0.9` for the cannula type
  """
  @type prime_type :: :manual | :fixed

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  `timestamp` when cannula was primed with `prime_type`.
  """
  @impl Pummpcomm.History.Decoder
  # TODO determine difference between `amount` and `programmed_amount`
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{
          programmed_amount: Insulin.units(),
          amount: Insulin.units(),
          prime_type: prime_type,
          timestamp: NaiveDateTime.t()
        }
  def decode(body, pump_options)

  def decode(
        <<_::8, raw_programmed_amount::8, _::8, raw_amount::8, timestamp::binary-size(5)>>,
        _
      ) do
    programmed_amount = (raw_programmed_amount <<< 2) / 40

    %{
      programmed_amount: programmed_amount,
      amount: (raw_amount <<< 2) / 40,
      prime_type: prime_type(programmed_amount),
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  defp prime_type(0.0), do: :manual
  defp prime_type(_), do: :fixed
end
