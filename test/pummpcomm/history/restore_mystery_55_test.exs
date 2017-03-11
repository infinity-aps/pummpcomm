defmodule Pummpcomm.History.RestoreMystery55Test do
  use ExUnit.Case

  test "Restore Mystery 55" do
    {:ok, history_page} = Base.decode16("5511004080810800050500FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF000F0F00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:restore_mystery_55, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
