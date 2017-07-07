defmodule Pummpcomm.Driver.SubgRfspyTest do
  use ExUnit.Case, async: false
  require Logger

  alias Pummpcomm.Driver.SubgRfspy
  alias Pummpcomm.Driver.SubgRfspy.Fake

  doctest SubgRfspy

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  setup(context) do
    {:ok, pid} = Fake.start_link(context[:test])
    on_exit(fn() -> assert_down(pid) end)
    :ok
  end

  @write_register "06"
  test "set base frequency writes correct register data" do
    SubgRfspy.set_base_frequency(916.500)

    # freq0 (0x09) should have the upper frequency byte of 0x26
    assert Enum.member?(Fake.interactions, ["write", @write_register <> "0926", "ok"])
    # freq1 (0x0A) should have the middle frequency byte of 0x30
    assert Enum.member?(Fake.interactions, ["write", @write_register <> "0A30", "ok"])
    # freq2 (0x0B) should have the lower frequency byte of 0x00
    assert Enum.member?(Fake.interactions, ["write", @write_register <> "0B00", "ok"])
  end

  test "sync interacts with the chip firmware correctly" do
    SubgRfspy.sync()

    assert Enum.member?(Fake.interactions, ["write", "01", "ok"])
    assert Enum.member?(Fake.interactions, ["write", "02", "ok"])
  end
end
