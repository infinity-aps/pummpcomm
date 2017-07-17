defmodule Pummpcomm.Session.Command do
  @enforce_keys [:opcode, :pump_serial]
  defstruct opcode: nil, params: <<>>, pump_serial: nil, retries: 2, timeout: 3, bytes_per_record: 64, max_records: 1,
    effect_time: 0.5

  alias Pummpcomm.Session.Command

  def payload(%Command{params: params}) do
    params_count = byte_size(params)
    filler_length = (64 - params_count) * 8
    <<params_count::size(8)>> <> params <> <<0::size(filler_length)>>
  end

  def short_payload(%Command{}), do: <<0x00>>

  def ack(pump_serial) do
    %Command{opcode: 0x06, pump_serial: pump_serial}
  end

  def write_cgm_timestamp(pump_serial) do
    %Command{opcode: 0x28, pump_serial: pump_serial}
  end

  def read_pump_model(pump_serial) do
    %Command{opcode: 0x8D, pump_serial: pump_serial}
  end

  def power_control(pump_serial, minutes \\ 10) do
    %Command{opcode: 0x5D, pump_serial: pump_serial, retries: 0, params: <<minutes::size(8)>>}
  end

  def read_history_page(pump_serial, page) do
    %Command{opcode: 0x80, pump_serial: pump_serial, params: <<page::size(8)>>, timeout: 5000}
  end

  def get_current_cgm_page(pump_serial) do
    %Command{opcode: 0xCD, pump_serial: pump_serial}
  end

  def read_cgm_page(pump_serial, page) do
    %Command{opcode: 0x9A, pump_serial: pump_serial, params: <<page::size(32)>>, timeout: 5000}
  end
end
