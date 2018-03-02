defmodule Pummpcomm.History.ChangeBasalProfilePatternTest do
  use ExUnit.Case

  test "Change Basal Profile Pattern" do
    {:ok, history_page} =
      Base.decode16(
        "080000404081083F000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
      )

    decoded_events = Pummpcomm.History.decode_records(history_page, %{})

    assert {:change_basal_profile_pattern,
            %{timestamp: ~N[2008-01-01 00:00:00], raw: ^history_page}} =
             Enum.at(decoded_events, 0)
  end
end
