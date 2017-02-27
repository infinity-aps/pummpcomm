defmodule Decocare.History.BasalProfileStart do
  use Bitwise
  alias Decocare.DateDecoder

  def decode_basal_profile_start(<<profile_index::8, timestamp::binary-size(5), raw_offset::8, rate::8, _::binary-size(1)>>) do
    %{
      rate: rate / 40,
      profile_index: profile_index,
      offset: raw_offset * 30 * 1000 * 60,
      timestamp: DateDecoder.decode_history_timestamp(timestamp),
    }
  end
end
