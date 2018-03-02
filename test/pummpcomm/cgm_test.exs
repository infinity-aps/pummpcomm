defmodule Pummpcomm.CgmTest do
  use ExUnit.Case
  alias Pummpcomm.Cgm

  doctest Cgm

  setup do
    {:ok, cgm_page} = Base.decode16("1028B6140813131313133F77")
    {:ok, cgm_page: cgm_page}
  end

  test "decodes correct number of events", %{cgm_page: cgm_page} do
    assert {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert length(decoded_events) == 6
  end

  test "decodes correct event types", %{cgm_page: cgm_page} do
    assert {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    event_types = decoded_events |> Enum.map(fn event -> elem(event, 0) end)

    assert event_types == [
             :sensor_timestamp,
             :nineteen_something,
             :nineteen_something,
             :nineteen_something,
             :nineteen_something,
             :nineteen_something
           ]
  end

  test "correctly assigns reference timestamps", %{cgm_page: cgm_page} do
    assert {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies sensor data" do
    {:ok, cgm_page} = Base.decode16("1028B614081A6D34")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:sensor_glucose_value, %{sgv: 52}} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies sensor weak signal" do
    {:ok, cgm_page} = Base.decode16("1028B6140802FE0D")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:sensor_weak_signal, _} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies sensor calibration" do
    {:ok, cgm_page} = Base.decode16("1028B61408010300037CE0")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:sensor_calibration, %{calibration_type: :waiting}} = Enum.at(decoded_events, 1)
    assert {:sensor_calibration, %{calibration_type: :meter_bg_now}} = Enum.at(decoded_events, 2)
  end

  test "correctly identifies sensor data high" do
    {:ok, cgm_page} = Base.decode16("1028B61408FF0716AB")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:sensor_data_high, %{sgv: 400}} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies sensor timestamp" do
    {:ok, cgm_page} = Base.decode16("1028B61408A53B")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)

    assert {:sensor_timestamp, %{timestamp: ~N[2016-02-08 20:54:00], event_type: :page_end}} =
             Enum.at(decoded_events, 0)
  end

  test "correctly identifies battery change" do
    {:ok, cgm_page} = Base.decode16("1028B6140A8579")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:battery_change, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies sensor status" do
    {:ok, cgm_page} = Base.decode16("1028B6140B9558")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)

    assert {:sensor_status, %{timestamp: ~N[2016-02-08 20:54:00], status_type: :on}} =
             Enum.at(decoded_events, 0)
  end

  test "correctly identifies date time change" do
    {:ok, cgm_page} = Base.decode16("1028B6140CE5BF")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:datetime_change, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies sensor sync" do
    {:ok, cgm_page} = Base.decode16("1028B6140DF59E")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:sensor_sync, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
  end

  test "correctly identifies calibrate bg for glucose history" do
    {:ok, cgm_page} = Base.decode16("A08F135B4F0E7A69")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)

    assert {:cal_bg_for_gh, %{amount: 160, timestamp: ~N[2015-05-19 15:27:00]}} =
             Enum.at(decoded_events, 0)
  end

  test "correctly identifies sensor calibration factor" do
    {:ok, cgm_page} = Base.decode16("8C120F13674F0F8EFC")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)

    assert {:sensor_calibration_factor, %{factor: 4.748, timestamp: ~N[2015-05-19 15:39:00]}} =
             Enum.at(decoded_events, 0)
  end

  test "correctly identifies 0x10 something" do
    {:ok, cgm_page} = Base.decode16("0000011028B6141013D8C4")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:ten_something, %{timestamp: ~N[2016-02-08 20:54:00]}} = Enum.at(decoded_events, 0)
    assert {:nineteen_something, _} = Enum.at(decoded_events, 1)
  end

  test "correctly identifies unknown opcodes" do
    {:ok, cgm_page} = Base.decode16("12D383")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert {:unknown, _} = Enum.at(decoded_events, 0)
  end

  test "slurps up zeros" do
    {:ok, cgm_page} = Base.decode16("000000CC9C")
    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)
    assert 3 == length(decoded_events)
    assert {:null_byte, _} = Enum.at(decoded_events, 2)
  end

  test "full page decode works as expected" do
    {:ok, cgm_page} =
      Base.decode16(
        "201E1D1C1A1817161718191B1D1B1C1F212527282A2E3235383C3FCD9086850E0E0000011006850E1043484857EB181006940E0F595E00000110069F0E106670757374767A7D7F8181817D7813726D6663605E5B554F4C4E4F4B484946423E3B38353234332D2B2B2B2C2E302F2F312F2D2D2E2D2C2D2D2A2B292700000110069F1310242323272B2C3235383C00000110069514103E3E3F404141444A4945413E3D3D3A35302C2823201D1B1C1D1A1A1B1C1E2123272B2F3231323235383B3F43484949474542779007A0000E41423D6C171007AD000F3C3D3D3B3C3E3F41474F545A626A6E700000011007860210717271727476797A7A7B7C7D7C7B777472706E6D6C6B6A6763605C5A6064636160605F5D5C5C5B5956545250555A585656555554565654504D4C4A484E515455555452504F4D4D504E4D4E505050504F4E4D4C4C4F50510000011007980910539290079C090E54554BC4141007A8090F4A4A49494C4C4D50515253524F53524F4D4C7590078E0B0E7590878E0B0E4A4947433BD0121007A30B0F373333312F2B26242423252526292A2A2A0000011007810D102A2A2828282B3337383A3F44474746484B4F52504B4846434343413D393500000110079F0F10312F2D2B27211E1D3F90078E100E1C1A191214100798100F181817181F20242A2E33383E41464B4B4F56595E000001100788121065686667660000011007A3121066686B6D6F727375777774707273706C6764615F5A575553453D39322C251F1A1C191614171D2124282C2E31353A3F4144484A4B4C4D50555B000001100790171061656A6665656768C99007B9170E0000011007B917106869659413100889000F625F5D5D5F5D5A56524B4E4E4C4B4847494B494A4D5051514F4E4C4E4E4D4B4A494A4B4B4B4B47474D4E4E4E4E4E4C4B4A46434B4D4C4B49490000011008B804104B4B4B4D515456565655545455595A5800000110088F0610595A5A595A595755555858575655545453525152534E4A474445484B4E4F13505251135113515051525154AF9088A6090E0000011008A6091052505594141008B3090F55565B5A58534F4B49134037132F28132320131A13181514151615171919191A1A1B1A1B1C1D202325242221225890088B0D0E00000110088C0D1023252AEC151008990D0F2B2B2E31393F3A3C41484E555D00000110089F0E1063696E73767A7C7D7F7E7F8085878689E59008B50F0E0000011008B50F10878979CD13100885100F76737272706D0000011008A71010696461605D5A57555352520000011008A11110504C4947484743434278900893120E0000011008941210423F3A3837D6131008A9120F33322F2E2F31322F2C2C2B2828292A2827243A90088E140E211C19181809141008A4140F191A19191028B6140813131313133C95"
      )

    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)

    reconstituted_cgm_page =
      decoded_events
      |> Enum.map(fn decoded_event -> elem(decoded_event, 1) end)
      |> Enum.map(fn event_map -> Map.fetch!(event_map, :raw) end)
      |> Enum.reduce(<<>>, fn raw, acc -> acc <> raw end)

    assert cgm_page ==
             reconstituted_cgm_page <>
               <<Pummpcomm.Crc.Crc16.crc_16(reconstituted_cgm_page)::size(16)>>

    assert !Cgm.needs_timestamp?(decoded_events)
  end

  test "needs sensor timestamp is true when pages needs a timestamp written" do
    {:ok, cgm_page} =
      Base.decode16(
        "110EEF4108110EEF4108110EEF41084C4B49474544434342424242413F3E3C3B3C3D3D3C3B3938373635333231302F2E2E2E2E2D2D2D2E303234353536363534353636343231302F2E2C2A2928292A2B2C2E2F3030302F2E2D2C2B2928282726262626272828292C2F31323232323167910EF2490E000001110EF249100103110EF44908110EF44908110EF4490801032F9514110EC44A0F110EC24A08110EC24A08110EC24A082D2A2725221F131D1C131C1D130213021302130213021302114ED64B081302110EDB4B08110EDB4B08110EDB4B081302114EE04B08114EE64B0B110EE04B08110EE04B08110EE04B08112ECF4C0D110EE04B08110EE04B08110EE04B08114EDC4C0B110EE04B08110EE04B08110EE04B08000001110EDB4D10110EE04B08110EE04B08110EE04B08000001110EEE5110110EE04B08110EE04B08110EE04B08110EEF560BAB910FC2410E000001110FC34110000001110FF14C10000001110FF04F10F2910FDC520E000001110FDD5210000001110FEF5510110EE04B08110EE04B08110EE04B081130D5490B1130D5490D00031110D349081110D349083E9110D8490E1110D349081110D349081110D34908010301031F31131110E3490F1110E249081110E249081110E249081D1D1D1D1C1B1B1D1E0000011110D54A101110D34A081110D34A081110D34A0821232426282A2D2F323437383736343332302F2E2E2C2925211E1C1A1918191A1C1E1F20202022260000011110EC4D102D1110EC4D081110EC4D0836410000011110C04E104C1110FB4D081110FB4D081110FB4D080000011110C44E101110FB4D081110FB4D081110FB4D08576066696B6B6B6A68676666E39110C44F0E1110FB4E081110FB4E081110FB4E0866667127151110D04F0F72737374E91110E74F0E757675FB141110F24F0F75750000011110C250100100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000D84B"
      )

    {:ok, decoded_events} = Pummpcomm.Cgm.decode(cgm_page)

    assert Cgm.needs_timestamp?(decoded_events)
  end
end
