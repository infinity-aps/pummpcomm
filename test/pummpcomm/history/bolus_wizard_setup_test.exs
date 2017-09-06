defmodule Pummpcomm.History.BolusWizardSetupTest do
  use ExUnit.Case

  test "Bolus Wizard Setup on 751" do
    {:ok, history_page} = Base.decode16("5A0A4A380F050F050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015110000A00000000000000000000000000000000000000000000000002F000000000000000000000000000000616A0000000000000000000000000000000000000000004F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{ large_format: true })
    expected_event_info = %{
      timestamp: ~N[2015-04-05 15:56:10],
      raw: history_page
    }
    assert {:bolus_wizard_setup, ^expected_event_info} = Enum.at(decoded_events, 0)
  end

  test "Bolus Wizard Setup on 722" do
    {:ok, history_page} = Base.decode16("5A0F845C0F061135110009160A1D0900000000000000000000001E000000000000000000000000000000507300000000000000000000000000000000000000000035110009160A1D0900000000000000000000001E000000000000000000000000000000505A00000000000000000000000000000000000000000033")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{ large_format: false })
    expected_event_info = %{
      timestamp: ~N[2017-09-06 15:28:04],
      raw: history_page
    }
    assert {:bolus_wizard_setup, ^expected_event_info} = Enum.at(decoded_events, 0)
  end
end
