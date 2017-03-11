defmodule Pummpcomm.History.EnableBolusWizardTest do
  use ExUnit.Case

  test "Enable Bolus Wizard" do
    {:ok, history_page} = Base.decode16("2D014A380F050F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:enable_bolus_wizard, %{timestamp: ~N[2015-04-05 15:56:10], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
