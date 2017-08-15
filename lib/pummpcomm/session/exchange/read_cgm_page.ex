defmodule Pummpcomm.Session.Exchange.ReadCgmPage do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response
  alias Pummpcomm.Cgm

  @opcode 0x9A
  def make(pump_serial, page) do
    %Command{opcode: @opcode, pump_serial: pump_serial, params: <<page::size(32)>>, timeout: 5000}
  end

  def decode(%Response{opcode: @opcode, data: data}) do
    Cgm.decode(data)
  end
end
