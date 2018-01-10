defmodule ReadStdBasalProfileTest do
  use ExUnit.Case

  alias Pummpcomm.Session.Exchange.ReadStdBasalProfile
  alias Pummpcomm.Session.Response

  test "decodes standard profile correctly" do
    profile_data = Base.decode16!("20000026000D2C001326001C00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    pump_response = %Response{opcode: 0x92, data: profile_data}

    expected_result = [
      %{start: ~T[00:00:00], rate: 0.80},
      %{start: ~T[06:30:00], rate: 0.95},
      %{start: ~T[09:30:00], rate: 1.10},
      %{start: ~T[14:00:00], rate: 0.95}
    ]

    assert {:ok, %{schedule: expected_result}} == ReadStdBasalProfile.decode(pump_response)
  end
end
