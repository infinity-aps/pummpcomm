defmodule Pummpcomm.Session.Exchange.ReadTime do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response
  alias Pummpcomm.DateDecoder

  @opcode 0x70
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  def decode(%Response{opcode: @opcode, data: <<encoded_date::binary-size(7), _::binary>>}) do
    DateDecoder.decode_full_datetime(encoded_date)
  end
end
