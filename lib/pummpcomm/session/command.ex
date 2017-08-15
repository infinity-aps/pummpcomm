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
end
