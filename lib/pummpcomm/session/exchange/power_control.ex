defmodule Pummpcomm.Session.Exchange.PowerControl do
  alias Pummpcomm.Session.Command

  @opcode 0x5D
  def make(pump_serial, minutes \\ 10) do
    %Command{opcode: @opcode, pump_serial: pump_serial, retries: 0, params: <<minutes::size(8)>>}
  end
end
