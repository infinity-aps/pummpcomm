defmodule Pummpcomm.Crc8Test do
  use ExUnit.Case
  doctest Pummpcomm.Crc8

  test "crc computation" do
    {:ok, data} = Base.decode16("A259705504A24117043A0E080B003D3D00015B030105D817790A0F00000300008B1702000E080B0000")
    assert Pummpcomm.Crc8.crc_8(<<data::binary-size(41)>>) == 0x71
  end
end
