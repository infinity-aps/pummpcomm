defmodule Pummpcomm.Command do
  @enforce_keys [:opcode, :pump_serial]
  defstruct opcode: nil, params: <<>>, pump_serial: nil, retries: 2, timeout: 3, bytes_per_record: 64, max_records: 1,
    effect_time: 0.5

  def payload(%Pummpcomm.Command{params: params}) do
    params_count = byte_size(params)
    filler_length = (63 - params_count) * 8
    <<params_count::size(8)>> <> params <> <<0::size(filler_length)>>
  end

  def short_payload(%Pummpcomm.Command{}) do
    <<0x00>>
  end

  def read_pump_model(pump_serial) do
    %Pummpcomm.Command{opcode: 0x8D, pump_serial: pump_serial}
  end

  def power_control(pump_serial, minutes \\ 10) do
    %Pummpcomm.Command{
      opcode: 0x5D,
      pump_serial: pump_serial,
      retries: 0,
      params: <<0x01, minutes::size(8)>>
    }
  end
end
