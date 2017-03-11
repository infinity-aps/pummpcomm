defmodule Pummpcomm.FourBySix do
  @codes [0b010101, 0b110001, 0b110010, 0b100011,
          0b110100, 0b100101, 0b100110, 0b010110,
          0b011010, 0b011001, 0b101010, 0b001011,
          0b101100, 0b001101, 0b001110, 0b011100]

  @doc """
  Converts a binary composed of 4-bit nibbles into the 6-bit radio code
  equivalent. Result is zero-appended to conform to a clean byte boundary for
  serial communication.
  """
  def encode(nibbles) do
    sixes = _encode(nibbles, <<>>)
    conform_to_byte_boundary(sixes, bit_size(sixes))
  end

  def _encode(<<>>, sixes), do: sixes
  def _encode(<<nibble::4, tail::bitstring>>, sixes) do
    six_bits = Enum.at(@codes, nibble)
    _encode(tail, <<sixes::bitstring, six_bits::size(6)>>)
  end

  @doc """
  Converts a binary composed of 6-bit radio codes into the 4-bit nibble equivalent.
  """
  def decode(sixes) do
    nibbles = _decode(sixes, <<>>)
    conform_to_byte_boundary(nibbles, bit_size(nibbles))
  end

  def _decode(<<val::bitstring>>, nibbles) when bit_size(val) < 6, do: nibbles
  def _decode(<<0b000000::6, _::bitstring>>, nibbles), do: nibbles
  def _decode(<<six_bits::6, tail::bitstring>>, nibbles) do
    nibble = Enum.find_index(@codes, fn (item) -> item == six_bits end)
    _decode(tail, <<nibbles::bitstring, nibble::(4)>>)
  end

  defp conform_to_byte_boundary(bits, bit_length) when rem(bit_length, 8) == 0, do: bits
  defp conform_to_byte_boundary(bits, bit_length) do
    bits_to_add = 8 - rem(bit_length, 8)
    <<bits::bitstring, 0::size(bits_to_add)>>
  end

  # def format_bits(code_bits) do
  #   :io_lib.format("~6.2B", [code_bits]) |> List.to_string |> String.replace(" ", "0")
  # end
end
