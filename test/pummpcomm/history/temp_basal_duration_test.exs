defmodule Pummpcomm.History.TempBasalDurationTest do
  use ExUnit.Case

  test "Temp Basal Duration" do
    {:ok, history_page} = Base.decode16("16010C9A144D11")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:temp_basal_duration, %{duration: 30, timestamp: ~N[2017-02-13 20:26:12], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
