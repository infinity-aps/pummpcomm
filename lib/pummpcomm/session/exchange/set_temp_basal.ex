defmodule Pummpcomm.Session.Exchange.SetTempBasal do
  @moduledoc """
  Sets temporary basal on pump.  This is the primary mechanism control for closed-loop users.
  """

  alias Pummpcomm.Insulin
  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @ack 0x06

  @opcode 0x4C

  @strokes_per_unit 40

  # Functions

  @doc """
  Decodes that set temporary basal command was acknowledged.
  """
  @spec decode(Response.t) :: :ok
  def decode(%Response{opcode: @ack, data: <<0>>}), do: :ok

  @doc """
  Makes `Pummpcomm.Session.Command.t` to set temporary basal to `units_per_hour` for `duration_minutes` on the pump with
  `pump_serial`
  """
  @spec make(
          Command.pump_serial,
          [units_per_hour: Insulin.units_per_hour, duration_minutes: non_neg_integer, type: :absolute]
        ) :: Command.t
  def make(pump_serial, units_per_hour: units_per_hour, duration_minutes: duration_minutes, type: :absolute) do
    binary_duration = round(duration_minutes / 30)
    binary_rate = round(units_per_hour * @strokes_per_unit)
    params = <<binary_rate::integer-size(16), binary_duration::8>>
    %Command{opcode: @opcode, pump_serial: pump_serial, params: params}
  end
end
