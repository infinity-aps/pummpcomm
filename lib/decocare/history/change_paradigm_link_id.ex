defmodule Decocare.History.ChangeParadigmLinkID do
  alias Decocare.DateDecoder

  def decode_change_paradigm_link_id(<<_::8, timestamp::binary-size(5), _::binary-size(14)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
