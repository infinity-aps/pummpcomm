defmodule Pummpcomm.Session.Exchange.ReadHistoryPage do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response
  alias Pummpcomm.History

  @opcode 0x80
  def make(pump_serial, page) do
    %Command{opcode: @opcode, pump_serial: pump_serial, params: <<page::size(8)>>, timeout: 5000}
  end

  def decode(%Response{opcode: @opcode, data: data}, pump_model) do
    History.decode(data, pump_model)
  end
end
