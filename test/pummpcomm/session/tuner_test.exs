defmodule Pummpcomm.Session.TunerTest do
  use UartCaseTemplate, async: false

  alias Pummpcomm.Session.Tuner

  doctest Tuner

  @tag timeout: 300_000
  test "tune returns a frequency and rssi", %{pump_serial: pump_serial} do
    assert {:ok, frequency, rssi} = Tuner.tune(pump_serial)
    assert is_number(frequency)
    assert rssi < 0
  end

  test "it chooses the best frequency based on successes and rssi" do
    # results of each scan are in the tuple form {frequency, successful_samples, rssi}
    example_frequency_scan_results = [
      {916.3,  0, -99.0}, {916.324, 0, -99.0}, {916.348, 0, -99.0}, {916.372, 0, -99.0}, {916.396, 0, -99.0},
      {916.42, 5, -55.5}, {916.444, 5, -48.5}, {916.468, 4, -57.8}, {916.492, 4, -57.8}, {916.516, 5, -47.5},
      {916.54, 5, -48.5}, {916.564, 5, -53.5}, {916.588, 0, -99.0}, {916.612, 0, -99.0}, {916.636, 0, -99.0},
      {916.66, 0, -99.0}, {916.684, 0, -99.0}, {916.708, 0, -99.0}, {916.732, 0, -99.0}, {916.756, 0, -99.0},
      {916.78, 0, -99.0}, {916.804, 0, -99.0}, {916.828, 0, -99.0}, {916.852, 0, -99.0}, {916.876, 0, -99.0}
    ]
    default_frequency = {915.9, -99.0}

    assert {916.516, -47.5} == Tuner.select_best_frequency(example_frequency_scan_results, default_frequency)
  end
end
