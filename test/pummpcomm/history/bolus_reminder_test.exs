defmodule Pummpcomm.History.BolusReminderTest do
  use ExUnit.Case

  test "Bolus Reminder" do
    {:ok, history_page} = Base.decode16("69089B0D0A1D0C0A1E")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{large_format: true})
    assert {:bolus_reminder, %{timestamp: ~N[2012-08-29 10:13:27], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
