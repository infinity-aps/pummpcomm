defmodule Pummpcomm.Session.Tuner do
  @moduledoc """
  This module is responsible for scanning the known US or WW pump frequencies and searching for the best one for a given
  pump. It samples 5 times in each of the 25 frequency steps within the range and measures the average rssi. The
  frequency which results in 5 successful responses and has the highest (closest to 0) rssi wins.
  """

  require Logger

  alias Pummpcomm.Radio.Chip
  alias Pummpcomm.Radio.ChipAgent
  alias Pummpcomm.Session.FourBySix
  alias Pummpcomm.Session.Packet
  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.ReadPumpModel

  @frequencies_by_region %{
    us: [916.45, 916.50, 916.55, 916.60, 916.65, 916.70, 916.75, 916.80],
    ww: [868.25, 868.30, 868.35, 868.40, 868.45, 868.50, 868.55, 868.60, 868.65]
  }

  def tune(pump_serial, radio_locale \\ :us) do
    Logger.info fn() -> "Tuning radio" end

    with frequencies <- @frequencies_by_region[radio_locale],
         default_frequency <- default_frequency(frequencies),
         {:ok} <- Chip.set_base_frequency(ChipAgent.current, default_frequency),
         _ <- PumpExecutor.ensure_pump_awake(pump_serial),
         test_command <- %{ReadPumpModel.make(pump_serial) | retries: 0},
         {:ok, test_packet} <- Packet.from_command(test_command, <<0x00>>),
         command_bytes <- Packet.to_binary(test_packet) do

      {best_frequency, avg_rssi} = frequencies
        |> scan_over_frequencies(command_bytes)
        |> select_best_frequency({default_frequency, -99})

      Logger.info fn() -> "Best frequency is #{best_frequency} with an rssi of #{avg_rssi}" end
      Chip.set_base_frequency(ChipAgent.current, best_frequency)
      {:ok, best_frequency, avg_rssi}

    else
      result -> Logger.error fn() -> "Could not determine best frequency: #{inspect result}" end
    end
  end

  def select_best_frequency([], best_frequency), do: best_frequency
  def select_best_frequency([{_, successes, _} | tail], best_frequency) when successes == 0, do: select_best_frequency(tail, best_frequency)
  def select_best_frequency([{frequency, _, rssi} | tail], best_frequency = {_, best_rssi}) do
    case rssi > best_rssi do
      true  -> select_best_frequency(tail, {frequency, rssi})
      false -> select_best_frequency(tail, best_frequency)
    end
  end

  defp default_frequency(frequencies) do
    Enum.at(frequencies, round(length(frequencies) / 2))
  end

  defp scan_over_frequencies(frequencies, command_bytes) do
    Enum.map(frequencies, fn(frequency) -> scan_frequency(frequency, command_bytes) end)
  end

  @samples 5
  defp scan_frequency(frequency, command_bytes) do
    Logger.debug fn() -> "Trying #{inspect(frequency)}" end
    {:ok} = Chip.set_base_frequency(ChipAgent.current, frequency)

    (1..@samples)
    |> Enum.map(fn(_) -> measure_communication(command_bytes) end)
    |> Enum.reduce({0, 0}, fn
      ({:error, rssi}, {successes, avg}) -> {successes    , avg + (rssi / @samples)}
      ({:ok,    rssi}, {successes, avg}) -> {successes + 1, avg + (rssi / @samples)}
    end)
    |> Tuple.insert_at(0, frequency)
  end

  defp measure_communication(command_bytes) do
    with {:ok, encoded} <- FourBySix.encode(command_bytes),
         {:ok, %{rssi: rssi}} <- Chip.write_and_read(ChipAgent.current, encoded, 80) do
      {:ok, rssi}
    else
      _ -> {:error, -99}
    end
  end
end
