defmodule Decocare.History.BolusWizardSetup do
  alias Decocare.DateDecoder

  def decode_bolus_wizard_setup(<<_::8, timestamp::binary-size(5), _::binary-size(137)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
