defmodule Pummpcomm.Driver.FourBySixTest do
  use ExUnit.Case

  alias Pummpcomm.Driver.FourBySix

  doctest FourBySix

  test "encode that lands on byte boundary" do
    result =  FourBySix.encode(<<0x1234::size(16)>>)
    assert result == <<0b110001::size(6), 0b110010::size(6), 0b100011::size(6), 0b110100::size(6), 0x00::8>>
  end

  test "encode with result that doesn't land on a byte boundary" do
    result = FourBySix.encode(<<0b1111::size(4), 0b0000::size(4)>>)
    assert result == <<0b011100::size(6), 0b010101::size(6), 0b0000::size(4), 0x00::8>>
  end

  test "decode with result that lands on byte boundary" do
    result = FourBySix.decode(<<0b011100::size(6), 0b010101::size(6), 0b0000::size(4)>>)
    assert result == <<0b1111::size(4), 0b0000::size(4)>>
  end

  test "decode with result that doesn't land on a byte boundary" do
    result = FourBySix.decode(<<0b110001::size(6), 0b110010::size(6), 0b100011::size(6)>>)
    assert result == <<0x1230::size(16)>>
  end
end
