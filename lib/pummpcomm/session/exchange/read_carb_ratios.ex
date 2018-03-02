defmodule Pummpcomm.Session.Exchange.ReadCarbRatios do
  @moduledoc """
  Read open intervals for carb ratios throughout the day
  """

  alias Pummpcomm.{Carbohydrates, Insulin}
  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @opcode 0x8A

  # Functions

  @doc """
  Decodes `Pummpcomm.Session.Response.t` to schedule of `Pummpcomm.Insulin.carbohydrates_per_unit` ratio for each
  open interval at `start`.
  """
  @spec decode(Response.t(), Pummpcomm.PumpModel.pump_model()) :: {
          :ok,
          %{
            units: Carbohydrates.units(),
            schedule: [
              %{
                ratio: Insulin.carbohydrates_per_unit(),
                start: NaiveDateTime.t()
              }
            ]
          }
        }

  def decode(%Response{opcode: @opcode, data: <<units::8, count::8, rest::binary>>}, model_number)
      when rem(model_number, 100) >= 23 do
    {:ok, %{units: decode_units(units), schedule: decode_larger_carb_ratio(rest, [], count)}}
  end

  def decode(%Response{opcode: @opcode, data: <<units::8, rest::binary>>}, _) do
    {:ok, %{units: decode_units(units), schedule: decode_smaller_carb_ratio(rest, [], 8)}}
  end

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read carb ratios from pump with `pump_serial`
  """
  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  ## Private Functions

  defp basal_time(raw_time) do
    Timex.now()
    |> Timex.beginning_of_day()
    |> Timex.shift(minutes: 30 * raw_time)
    |> DateTime.to_time()
  end

  defp decode_larger_carb_ratio(_, carb_ratios, count) when count == 0,
    do: Enum.reverse(carb_ratios)

  defp decode_larger_carb_ratio(
         <<raw_time::8, raw_ratio::binary-size(2), rest::binary>>,
         carb_ratios,
         count
       ) do
    carb_ratio = %{ratio: decode_ratio(raw_ratio), start: basal_time(raw_time)}
    decode_larger_carb_ratio(rest, [carb_ratio | carb_ratios], count - 1)
  end

  defp decode_ratio(<<raw_ratio::8>>), do: raw_ratio / 1
  defp decode_ratio(<<0x00::8, raw_ratio::8>>), do: raw_ratio / 10
  defp decode_ratio(<<raw_ratio::16>>), do: raw_ratio / 1000

  defp decode_smaller_carb_ratio(_, carb_ratios, count) when count == 0,
    do: Enum.reverse(carb_ratios)

  defp decode_smaller_carb_ratio(<<_::8, raw_ratio::8, _::binary>>, carb_ratios, _)
       when raw_ratio == 0 and length(carb_ratios) > 0,
       do: Enum.reverse(carb_ratios)

  defp decode_smaller_carb_ratio(
         <<raw_time::8, raw_ratio::binary-size(1), rest::binary>>,
         carb_ratios,
         count
       ) do
    carb_ratio = %{ratio: decode_ratio(raw_ratio), start: basal_time(raw_time)}
    decode_smaller_carb_ratio(rest, [carb_ratio | carb_ratios], count - 1)
  end

  defp decode_units(0x01), do: :grams
  defp decode_units(0x02), do: :exchanges
end
