defmodule Pummpcomm.Driver.SubgRfspyTest do
  use ExUnit.Case

  alias Pummpcomm.Driver.SubgRfspy

  doctest SubgRfspy

  test "record test" do
    device = "/dev/tty.usbserial-00002014"
    Pummpcomm.Driver.SubgRfspy.Fake.start_link("RecordTest", true, device)
    Pummpcomm.Driver.SubgRfspy.sync()
    Pummpcomm.Driver.SubgRfspy.set_base_frequency(916.500)
    Pummpcomm.Session.Pump.power_control("856188")
    IO.inspect Pummpcomm.Driver.SubgRfspy.Fake.interactions
  end
end
