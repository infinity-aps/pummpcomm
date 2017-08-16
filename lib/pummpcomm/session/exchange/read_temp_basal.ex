defmodule Pummpcomm.Session.Exchange.ReadTempBasal do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0x98
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  @strokes_per_unit 40 # X12 and above
  def decode(%Response{opcode: @opcode, data: <<0::8, _::8, raw_rate::16, duration::16, _::binary>>}) do
    %{type: :absolute, rate: raw_rate / @strokes_per_unit, duration: duration}
  end

  def decode(%Response{opcode: @opcode, data: <<1::8, rate::8, _::16, duration::16, _::binary>>}) do
    %{type: :percent, rate: rate, duration: duration}
  end
end
