defmodule Pummpcomm.History.ChangeBolusWizardEstimateTest do
  use ExUnit.Case

  test "Change Bolus Wizard Setup" do
    {:ok, history_page}=Base.decode16("4F000CA1090E112151008C37281E003C14001E3C25853E2051008C37281E003C14001E3C25853E")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    expected_event_info = %{
      timestamp: ~N[2017-02-14 09:33:12],
      raw: history_page
    }
    assert {:change_bolus_wizard_setup, ^expected_event_info} = Enum.at(decoded_events, 0)
  end
end
