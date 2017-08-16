defmodule Pummpcomm.Session.Exchange.ReadPumpStatus do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response

  @opcode 0xCE
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  def decode(%Response{opcode: @opcode, data: <<_::8, bolusing::8, suspended::8, _rest::binary>>}) do
    %{bolusing: decode_bool(bolusing), suspended: decode_bool(suspended)}
  end

  defp decode_bool(0), do: false
  defp decode_bool(_), do: true
end
