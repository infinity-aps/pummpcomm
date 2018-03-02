defmodule Pummpcomm.History.BasalProfileStart do
  @moduledoc """
  When a basal rate started.
  """
  alias Pummpcomm.DateDecoder

  @doc """
  `timestamp` basal `rate` at `profile_index` started at `offset`
  """
  @spec decode(<<_::72>>, term) :: %{
          # TODO determine units of rate and turn into a @type
          rate: float,
          profile_index: byte,
          # TODO determine units of offset and turn into a @type
          offset: non_neg_integer,
          timestamp: NaiveDateTime.t()
        }
  def decode(body, pump_options)

  def decode(
        <<profile_index::8, timestamp::binary-size(5), raw_offset::8, rate::8, _::binary-size(1)>>,
        _
      ) do
    %{
      rate: rate / 40,
      profile_index: profile_index,
      offset: raw_offset * 30 * 1000 * 60,
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
