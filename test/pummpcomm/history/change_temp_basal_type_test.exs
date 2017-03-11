defmodule Pummpcomm.History.ChangeTempBasalTypeTest do
  use ExUnit.Case

  test "Change Temp Basal Type" do
    {:ok, history_page} = Base.decode16("620175110C050F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_temp_basal_type, %{basal_type: :percent, timestamp: ~N[2015-04-05 12:17:53], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
