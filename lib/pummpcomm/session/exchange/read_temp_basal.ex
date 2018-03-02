defmodule Pummpcomm.Session.Exchange.ReadTempBasal do
  @moduledoc """
  Reads temporay basal from pump
  """

  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @opcode 0x98

  # X12 and above
  @strokes_per_unit 40

  # Functions

  def decode(%Response{
        opcode: @opcode,
        data: <<0::8, _::8, raw_rate::16, duration::16, _::binary>>
      }) do
    {:ok, %{type: :absolute, units_per_hour: raw_rate / @strokes_per_unit, duration: duration}}
  end

  def decode(%Response{opcode: @opcode, data: <<1::8, rate::8, _::16, duration::16, _::binary>>}) do
    {:ok, %{type: :percent, units_per_hour: rate, duration: duration}}
  end

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read temp basal.
  """
  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end
end
