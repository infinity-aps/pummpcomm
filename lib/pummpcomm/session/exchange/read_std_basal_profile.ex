defmodule Pummpcomm.Session.Exchange.ReadStdBasalProfile do
  @moduledoc """
  Reads standard pump basal profiles
  """

  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @opcode 0x92
  @rate_multiplier 0.025

  # Functions

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read the standard basal profile
  """
  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  @doc """
  Decodes `Pummpcomm.Session.Response.t` to the standard basal profile schedule
  with each open interval starting at `start`.
  """
  @spec decode(Response.t()) :: {
          :ok,
          %{
            schedule: [
              %{
                rate: float(),
                start: NaiveDateTime.t()
              }
            ]
          }
        }
  def decode(%Response{opcode: @opcode, data: <<targets::binary>>}) do
    {:ok, %{schedule: decode_schedule(targets, [])}}
  end

  ## Private Functions

  defp basal_time(raw_time) do
    Timex.now()
    |> Timex.beginning_of_day()
    |> Timex.shift(minutes: 30 * raw_time)
    |> DateTime.to_time()
  end

  defp decode_schedule(<<>>, decoded_targets), do: Enum.reverse(decoded_targets)
  defp decode_schedule(<<0::24, _::binary>>, decoded_targets), do: Enum.reverse(decoded_targets)

  defp decode_schedule(<<rate::8, _::8, minutes::8, rest::binary>>, decoded_targets) do
    change = %{start: basal_time(minutes), rate: Float.round(rate * @rate_multiplier, 3)}
    decode_schedule(rest, [change | decoded_targets])
  end
end
