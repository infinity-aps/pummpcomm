defmodule Pummpcomm.Session.Exchange.ReadInsulinSensitivities do
  @moduledoc """
  Reads insulin sensitivities throughout the day.
  """

  use Bitwise

  alias Pummpcomm.Insulin
  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @max_count 8

  @mgdl 1
  @mmol 2

  @opcode 0x8B

  # Functions

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read insulin sensitivities throughout the day from pump with `pump_serial`
  """
  @spec make(Command.pump_serial) :: Command.t
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  @doc """
  Decodes `Pummpcomm.Session.Response.t` to insulin sensitivites
  """
  @spec decode(Response.t) :: {
                                :ok,
                                %{
                                  units: String.t,
                                  sensitivities: [
                                    %{sensitivity: Insulin.blood_glucose_per_unit, start: NaiveDateTime.t}
                                  ]
                                }
                              }
  def decode(%Response{opcode: @opcode, data: <<units::8, rest::binary>>}) do
    {:ok, %{units: decode_units(units), sensitivities: decode_sensitivity(rest, [], @max_count, units)}}
  end

  ## Private Functions

  defp basal_time(raw_time) do
    Timex.now()
    |> Timex.beginning_of_day()
    |> Timex.shift(minutes: 30 * raw_time)
    |> DateTime.to_time()
  end

  defp convert_sensitivity_value(@mgdl, sensitivity), do: sensitivity
  defp convert_sensitivity_value(@mmol, sensitivity), do: sensitivity / 10

  defp decode_sensitivity(_, decoded_sensitivities, 0, _), do: Enum.reverse(decoded_sensitivities)
  defp decode_sensitivity(<<_::2, 0::6, _::binary>>, decoded_sensitivities, _, _) when length(decoded_sensitivities) > 0, do: Enum.reverse(decoded_sensitivities)
  defp decode_sensitivity(<<0::1, sensitivity_high::1, start_time::6, sensitivity_low::8, rest::binary>>, decoded_sensitivities, count, units) do
    sensitivity = (sensitivity_high <<< 8) + sensitivity_low
    decoded = %{start: basal_time(start_time), sensitivity: convert_sensitivity_value(units, sensitivity)}
    decode_sensitivity(rest, [decoded | decoded_sensitivities], count - 1, units)
  end

  defp decode_units(@mgdl), do: "mg/dL"
  defp decode_units(@mmol), do: "mmol/L"
end
