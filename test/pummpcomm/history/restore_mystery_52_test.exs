defmodule Pummpcomm.History.RestoreMystery52Test do
  use ExUnit.Case

  test "Restore Mystery 52" do
    {:ok, history_page} = Base.decode16("52000040008108")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:restore_mystery_52, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
