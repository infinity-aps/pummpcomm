defmodule Pummpcomm.Monitor.Loop do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:loop, state) do
    Logger.warn "Getting sensor values"
    Logger.warn "Got: #{inspect(Pummpcomm.Monitor.BloodGlucoseMonitor.get_sensor_values(20))}"
    schedule_work()
    {:noreply, state}
  end

  @after_period 5 * 60 * 1000 # 5 minutes
  defp schedule_work() do
    Process.send_after(self(), :loop, @after_period)
  end
end
