defmodule Pummpcomm.Session.Exchange.ReadRemainingInsulin do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0x73
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  def decode(%Response{opcode: @opcode, data: <<raw_remaining_insulin::16, _::binary>>}, strokes_per_unit = 10) do
    %{remaining_insulin: raw_remaining_insulin / strokes_per_unit}
  end

  def decode(%Response{opcode: @opcode, data: <<_::16, raw_remaining_insulin::16, _::binary>>}, strokes_per_unit = 40) do
    %{remaining_insulin: raw_remaining_insulin / strokes_per_unit}
  end
end
