defmodule Pummpcomm.Session.Exchange.GetCurrentCgmPage do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0xCD
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  def decode(%Response{opcode: @opcode, data: <<page_number::size(32), glucose::size(16), isig::size(16), _rest::binary>>}) do
    %{page_number: page_number, glucose: glucose, isig: isig}
  end
end
