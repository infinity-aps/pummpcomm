defmodule Pummpcomm.Crc.Crc16 do
  @moduledoc """
  16-bit [Cyclic Redundancy Check](https://en.wikipedia.org/wiki/Cyclic_redundancy_check).
  """

  use Bitwise

  # Constants

  @crc_table [0, 4129, 8258, 12387, 16516, 20645, 24774, 28903, 33032, 37161, 41290, 45419, 49548, 53677, 57806, 61935,
              4657, 528, 12915, 8786, 21173, 17044, 29431, 25302, 37689, 33560, 45947, 41818, 54205, 50076, 62463,
              58334, 9314, 13379, 1056, 5121, 25830, 29895, 17572, 21637, 42346, 46411, 34088, 38153, 58862, 62927,
              50604, 54669, 13907, 9842, 5649, 1584, 30423, 26358, 22165, 18100, 46939, 42874, 38681, 34616, 63455,
              59390, 55197, 51132, 18628, 22757, 26758, 30887, 2112, 6241, 10242, 14371, 51660, 55789, 59790, 63919,
              35144, 39273, 43274, 47403, 23285, 19156, 31415, 27286, 6769, 2640, 14899, 10770, 56317, 52188, 64447,
              60318, 39801, 35672, 47931, 43802, 27814, 31879, 19684, 23749, 11298, 15363, 3168, 7233, 60846,  64911,
              52716, 56781, 44330, 48395, 36200, 40265, 32407, 28342, 24277, 20212, 15891, 11826, 7761, 3696, 65439,
              61374, 57309, 53244, 48923, 44858, 40793, 36728, 37256, 33193, 45514, 41451, 53516, 49453, 61774, 57711,
              4224, 161, 12482, 8419, 20484, 16421, 28742, 24679, 33721, 37784, 41979, 46042, 49981, 54044, 58239,
              62302, 689, 4752, 8947, 13010, 16949, 21012, 25207, 29270, 46570, 42443, 38312, 34185, 62830, 58703,
              54572, 50445, 13538, 9411, 5280, 1153, 29798, 25671, 21540, 17413, 42971, 47098, 34713, 38840, 59231,
              63358, 50973, 55100, 9939, 14066, 1681, 5808, 26199, 30326, 17941, 22068, 55628, 51565, 63758, 59695,
              39368, 35305, 47498, 43435, 22596, 18533, 30726, 26663, 6336, 2273, 14466, 10403, 52093, 56156, 60223,
              64286, 35833, 39896, 43963, 48026, 19061, 23124, 27191, 31254, 2801, 6864, 10931, 14994, 64814, 60687,
              56684, 52557, 48554, 44427, 40424,  36297, 31782, 27655, 23652, 19525, 15522, 11395, 7392, 3265, 61215,
              65342, 53085, 57212, 44955, 49082, 36825, 40952, 28183, 32310, 20053, 24180, 11923, 16050, 3793, 7920]

  # Functions

  @doc """
  Checks CRC16 sent in `page` matches CRC16 calculated from rest of `page`.

  ## Returns

  * `{:error, "Page is too short"}` - if the page is too short
  * `{:fail, "<actual-crc-16> does not match <expected-crc-16>"}` - CRC16 in page does not match calculated CRC16 for
      page
  * `{:ok, expected_crc16}` - `expected_crc16` extracted from `page`.

  """
  @spec check_crc_16(binary) ::
          {:error, String.t()} | {:fail, String.t()} | {:ok, non_neg_integer}

  def check_crc_16(page) when byte_size(page) <= 2 do
    {:error, "Page is too short"}
  end

  def check_crc_16(page) do
    crc_data = crc_data(page)
    computed_crc = crc_16(page_data(page))

    case crc_data == computed_crc do
      false ->
        {:fail,
         "#{Integer.to_string(computed_crc, 16)} does not match #{Integer.to_string(crc_data, 16)}"}

      true ->
        {:ok, crc_data}
    end
  end

  @doc """
  CRC16 of `binary`
  """
  @spec crc_16(binary) :: non_neg_integer
  def crc_16(binary), do: crc_16(binary, 0xFFFF)

  @doc """
  The section of `page` that does not contain the `crc_data`
  """
  @spec page_data(binary) :: binary
  def page_data(page), do: :binary.part(page, 0, byte_size(page) - 2)

  ## Private Functions

  defp crc_16(<<>>, crc), do: crc

  defp crc_16(<<data::unsigned-integer-size(8), tail::binary>>, crc) do
    idx = (crc >>> 8) ^^^ data &&& 0xFF
    crc = (crc <<< 8) ^^^ Enum.at(@crc_table, idx) &&& 0xFFFF
    crc_16(tail, crc)
  end

  defp crc_data(page),
    do: page |> :binary.part(byte_size(page) - 2, 2) |> :binary.decode_unsigned()
end
