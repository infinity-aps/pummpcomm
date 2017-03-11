defmodule Pummpcomm.History.ChangeBolusScrollStepSizeTest do
  use ExUnit.Case

  test "Change Bolus Scroll Step Size" do
    {:ok, history_page} = Base.decode16("571956380F050F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_bolus_scroll_step_size, %{timestamp: ~N[2015-04-05 15:56:22], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
