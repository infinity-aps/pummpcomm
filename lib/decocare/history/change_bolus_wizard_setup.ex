defmodule Decocare.History.ChangeBolusWizardSetup do
  use Bitwise
  alias Decocare.DateDecoder

  def decode_change_bolus_wizard_setup(<<_::8, timestamp::binary-size(5), _::binary-size(32)>>) do
    %{
      timestamp: DateDecoder.decode_history_timestamp(timestamp)
    }
  end
end
