defmodule Pummpcomm.History.ChangeParadigmLinkIDTest do
  use ExUnit.Case

  test "Change Paradigm Link ID" do
    {:ok, history_page} = Base.decode16("3C0000400081083D0000000000003E000000000000")
    decoded_events = Pummpcomm.History.decode_records(history_page, %{})
    assert {:change_paradigm_link_id, %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} = Enum.at(decoded_events, 0)
  end
end
