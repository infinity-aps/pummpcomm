defmodule Pummpcomm.Session.Exchange.SetTempBasal do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0x4C
  @strokes_per_unit 40
  def make(pump_serial, units_per_hour: units_per_hour, duration: duration_minutes, type: :absolute) do
    binary_duration = round(duration_minutes / 30)
    binary_rate = round(units_per_hour * @strokes_per_unit)
    params = <<binary_rate::integer-size(16), binary_duration::8>>
    %Command{opcode: @opcode, pump_serial: pump_serial, params: params}
  end

  @ack 0x06
  def decode(%Response{opcode: @ack, data: <<0>>}), do: :ok
end
