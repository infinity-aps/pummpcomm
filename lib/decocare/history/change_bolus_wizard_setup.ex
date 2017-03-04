defmodule Decocare.History.ChangeBolusWizardSetup do
  use Bitwise
  alias Decocare.DateDecoder

  def decode(<<_::8, timestamp::binary-size(5), _::binary-size(32)>>, _) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
