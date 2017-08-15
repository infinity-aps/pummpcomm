defmodule Pummpcomm.Session.Exchange.WriteCgmTimestamp do
  alias Pummpcomm.Session.Command

  @opcode 0x28
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end
end
