defmodule Pummpcomm.History.ClearSettingsTest do
  use ExUnit.Case

  test "Clear Settings" do
    {:ok, history_page} = Base.decode16("2200400D0B050F")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:clear_settings, %{timestamp: ~N[2015-04-05 11:13:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
