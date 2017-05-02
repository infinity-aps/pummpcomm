defmodule Pummpcomm.Driver.FourBySixTest do
  use ExUnit.Case

  alias Pummpcomm.Driver.FourBySix

  doctest FourBySix

  test "encode that lands on byte boundary" do
    {:ok, result} = FourBySix.encode(<<0x1234::size(16)>>)
    assert result == <<0b110001::size(6), 0b110010::size(6), 0b100011::size(6), 0b110100::size(6), 0x00::8>>
  end

  test "encode with result that doesn't land on a byte boundary" do
    {:ok, result} = FourBySix.encode(<<0b1111::size(4), 0b0000::size(4)>>)
    assert result == <<0b011100::size(6), 0b010101::size(6), 0b0000::size(4), 0x00::8>>
  end

  test "decode" do
    {:ok, result} = FourBySix.decode(<<0b011100::size(6), 0b010101::size(6), 0b0000::size(4)>>)
    assert result == <<0b1111::size(4), 0b0000::size(4)>>
  end

  test "decode with bad data" do
    assert {:error, _} = FourBySix.decode(<<0b111111::size(6), 11::size(2)>>)
  end
end
