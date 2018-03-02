defmodule Pummpcomm.History.StandardEvent do
  @moduledoc """
  An event that only has a `timestamp`
  """

  alias Pummpcomm.DateDecoder

  @doc """
  `timestamp` when event happened
  """
  @spec decode(binary, Pummpcomm.PumpModel.pump_options()) :: %{
          required(:timestamp) => NaiveDateTime.t()
        }
  def decode(body, pump_options)

  def decode(<<_::8, timestamp::binary-size(5), _::binary>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
