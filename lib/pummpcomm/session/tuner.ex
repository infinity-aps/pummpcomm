defmodule Pummpcomm.Session.Tuner do
  require Logger

  alias Pummpcomm.Driver.SubgRfspy
  alias Pummpcomm.Session.Packet
  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.ReadPumpModel

  @frequency_ranges %{
    us: %{ start: 916.300, end: 916.900, default: 916.630 },
    ww: %{ start: 868.150, end: 868.750, default: 868.328 }
  }

  def tune(pump_serial, radio_locale \\ :us) do
    Logger.info fn() -> "Tuning radio" end

    with frequency_range <- @frequency_ranges[radio_locale],
         {:ok} <- SubgRfspy.set_base_frequency(frequency_range[:default]),
         _ <- PumpExecutor.ensure_pump_awake(pump_serial),
         test_command <- %{ReadPumpModel.make(pump_serial) | retries: 0},
         {:ok, test_packet} <- Packet.from_command(test_command, <<0x00>>),
         command_bytes <- Packet.to_binary(test_packet) do

      {best_frequency, avg_rssi} = frequency_range
        |> scan_over_frequencies(command_bytes)
        |> select_best_frequency({frequency_range[:default], -99})

      Logger.info fn() -> "Best frequency is #{best_frequency} with an rssi of #{avg_rssi}" end
      SubgRfspy.set_base_frequency(best_frequency)
      {:ok, best_frequency, avg_rssi}

    else
      result -> Logger.error fn() -> "Could not determine best frequency: #{inspect result}" end
    end
  end

  def select_best_frequency([], best_frequency), do: best_frequency
  def select_best_frequency([{_, successes, _} | tail], best_frequency) when successes < 5, do: select_best_frequency(tail, best_frequency)
  def select_best_frequency([{frequency, 5, rssi} | tail], best_frequency = {_, best_rssi}) do
    case rssi > best_rssi do
      true  -> select_best_frequency(tail, {frequency, rssi})
      false -> select_best_frequency(tail, best_frequency)
    end
  end

  @steps 25
  defp scan_over_frequencies(frequency_range, command_bytes, steps \\ @steps) do
    frequencies = frequencies_to_try(frequency_range, steps)
    Enum.map(frequencies, fn(frequency) -> scan_frequency(frequency, command_bytes) end)
  end

  defp frequencies_to_try(%{start: start_frequency, end: end_frequency}, steps) do
    step_size = (end_frequency - start_frequency) / steps
    Enum.map((0..(steps - 1)), fn(step) -> start_frequency + (step_size * step) end)
  end

  @samples 5
  defp scan_frequency(frequency, command_bytes) do
    {:ok} = SubgRfspy.set_base_frequency(frequency)

    (1..@samples)
    |> Enum.map(fn(_) -> measure_communication(command_bytes) end)
    |> Enum.reduce({0, 0}, fn
      ({:error, rssi}, {successes, avg}) -> {successes    , avg + (rssi / @samples)}
      ({:ok,    rssi}, {successes, avg}) -> {successes + 1, avg + (rssi / @samples)}
    end)
    |> Tuple.insert_at(0, frequency)
  end

  defp measure_communication(command_bytes) do
    with {:ok, %{rssi: rssi}} <- SubgRfspy.write_and_read(command_bytes, 80) do
      {:ok, rssi}
    else
      _ -> {:error, -99}
    end
  end
end
