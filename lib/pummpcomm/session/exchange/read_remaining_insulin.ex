defmodule Pummpcomm.Session.Exchange.ReadRemainingInsulin do
  @moduledoc """
  Reads remaining `Pummpcomm.Insulin.units` left in reservoir.
  """

  alias Pummpcomm.Insulin
  alias Pummpcomm.Session.{Command, Response}

  # Constants

  @opcode 0x73

  # Functions

  @doc """
  Decodes remaining `Pummpcomm.Insulin.units` left in reservoir from `Pummpcomm.Session.Response.t` to `make/1`
  `Pummpcomm.Session.Command.t`.
  """
  @spec decode(Response.t(), Pummpcomm.PumpModel.strokes_per_unit()) ::
          {:ok, %{remaining_insulin: Insulin.units()}}
  def decode(
        %Response{opcode: @opcode, data: <<raw_remaining_insulin::16, _::binary>>},
        strokes_per_unit = 10
      ) do
    {:ok, %{remaining_insulin: raw_remaining_insulin / strokes_per_unit}}
  end

  def decode(
        %Response{opcode: @opcode, data: <<_::16, raw_remaining_insulin::16, _::binary>>},
        strokes_per_unit = 40
      ) do
    {:ok, %{remaining_insulin: raw_remaining_insulin / strokes_per_unit}}
  end

  @doc """
  Makes `Pummpcomm.Session.Command.t` to read remaining `Pummpcomm.Insulin.units` in reservoir from pump with
  `pump_serial`.
  """
  @spec make(Command.pump_serial()) :: Command.t()
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end
end
