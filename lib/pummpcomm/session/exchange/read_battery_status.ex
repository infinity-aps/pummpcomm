defmodule Pummpcomm.Session.Exchange.ReadBatteryStatus do
  @moduledoc """
  Read battery indicator and voltage
  """

  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @opcode 0x72

  # Types

  @typedoc """
  * `:normal` - battery voltage is normal.
  * `:low` - battery voltage is low.  Replace battery soon.
  """
  @type indicator :: :low | :normal

  @typedoc """
  Battery voltage.  Resolution in 100th of a volt.
  """
  @type voltage :: float

  # Functions

  @doc """
  Decode battery `indicator` and `voltage` from `Pummpcomm.Session.Response` to `make/1` `Pummpcomm.Session.Command`.
  """
  @spec decode(Response.t) :: {:ok, %{indicator: indicator, voltage: voltage}}
  def decode(%Response{opcode: @opcode, data: <<indicator::8, raw_voltage::size(16), _rest::binary>>}) do
    {:ok, %{indicator: decode_indicator(indicator), voltage: raw_voltage / 100.0}}
  end

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read battry status from pump with `pump_serial`
  """
  @spec make(Command.pump_serial) :: Command.t
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  ## Private Functions

  defp decode_indicator(0), do: :normal
  defp decode_indicator(1), do: :low
end
