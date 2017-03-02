defmodule Decocare.History.EnableBolusWizard do
  alias Decocare.DateDecoder

  def decode_enable_bolus_wizard(<<_::8, timestamp::binary-size(5)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end