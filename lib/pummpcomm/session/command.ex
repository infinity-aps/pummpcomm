defmodule Pummpcomm.Session.Command do
  @moduledoc """
  A command issued during a `Pummpcomm.Session`
  """

  alias Pummpcomm.Session.Command

  # Struct

  @enforce_keys [:opcode, :pump_serial]
  defstruct opcode: nil,
            params: <<>>,
            pump_serial: nil,
            retries: 2,
            timeout: 3,
            bytes_per_record: 64,
            max_records: 1,
            effect_time: 0.5

  # Types

  @typedoc """
  Serial number of the pump
  """
  @type pump_serial :: String.t()

  @typedoc """
  * `opcode` - opcode for the command in the wireless protocol
  * `params` - binary parameters specific to `opcode`
  * `pump_serial` - which pump to issue the command to
  * `retries` - the number of times to retry the command
  * `timeout` - how long to wait between retries
  * `bytes_per_record` - the number of bytes per record
  * `max_records` - the maximum number of records
  """
  @type t :: %Command{
          opcode: non_neg_integer,
          params: binary,
          pump_serial: pump_serial,
          retries: non_neg_integer,
          timeout: pos_integer,
          bytes_per_record: pos_integer,
          max_records: pos_integer
        }

  # Functions

  def payload(%Command{params: params}) do
    params_count = byte_size(params)
    filler_length = (64 - params_count) * 8
    <<params_count::size(8)>> <> params <> <<0::size(filler_length)>>
  end

  def short_payload(%Command{}), do: <<0x00>>
end
