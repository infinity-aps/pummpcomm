defmodule Pummpcomm.Session.Exchange.Ack do
  alias Pummpcomm.Session.Command

  @opcode 0x06
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end
end
