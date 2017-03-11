defmodule Pummpcomm.History.PumpResumeTest do
  use ExUnit.Case

  test "Pump Resume" do
    {:ok, history_page} = Base.decode16("1F00308E0E0E11")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:pump_resume, %{timestamp: ~N[2017-02-14 14:14:48], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
