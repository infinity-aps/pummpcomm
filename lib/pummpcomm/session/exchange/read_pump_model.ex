defmodule Pummpcomm.Session.Exchange.ReadPumpModel do
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Response
  alias Pummpcomm.PumpModel

  @opcode 0x8D
  def make(pump_serial) do
    %Command{opcode: @opcode, pump_serial: pump_serial}
  end

  def decode(%Response{opcode: @opcode, data: <<length::8, rest::binary>>}) do
    {:ok, model_number} = PumpModel.model_number(binary_part(rest, 0, length))
    %{model_number: model_number}
  end
end
