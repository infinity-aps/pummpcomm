defmodule Pummpcomm.History.MealMarker do
  @moduledoc """
  When a user ate
  """

  use Bitwise

  alias Pummpcomm.{Carbohydrates, DateDecoder}

  @behaviour Pummpcomm.History.Decoder

  # Functions

  ## Pummpcomm.History.Decoder callbacks

  @doc """
  Decodes `body` to when the user ate
  """
  @impl Pummpcomm.History.Decoder
  @spec decode(binary, Pummpcomm.PumpModel.pump_options) :: %{
                                                              carbohydrates: Carbohydrates.carbohydrates,
                                                              carb_units: Carbohydrates.units,
                                                              timestamp: NaiveDateTime.t
                                                            }
  def decode(body, pump_options)
  def decode(<<_::7, carb_high_bit::1, timestamp::binary-size(5), carb_low_bits::8, _::6, unit_bit::1, _::1>>, _) do
    units = units(unit_bit)
    %{
      carbohydrates: carbohydrates(carb_high_bit, carb_low_bits, units),
      carb_units: units,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end

  ## Private Functions

  @spec carbohydrates(0 | 1, 0..127, :exchanges) :: float
  defp carbohydrates(_,             carb_low_bits, :exchanges), do: carb_low_bits / 10.0
  @spec carbohydrates(0 | 1, 0..127, :grams) :: non_neg_integer
  defp carbohydrates(carb_high_bit, carb_low_bits, :grams),     do: (carb_high_bit <<< 8) + carb_low_bits

  defp units(0x00), do: :grams
  defp units(0x01), do: :exchanges
end
