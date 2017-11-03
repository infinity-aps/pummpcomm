defmodule Pummpcomm.DriverSupervisor do
  use Supervisor
  require Logger

  def start_link(local_timezone, pump_module, cgm_module, pump_serial) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, [])
    start_workers(sup, local_timezone, pump_module, cgm_module, pump_serial)
    result
  end

  def start_workers(sup, local_timezone, pump_module, cgm_module, pump_serial) do
    Supervisor.start_child(sup, worker(Pummpcomm.DriverSelector, []))
    [pump_module, cgm_module]
    |> Enum.uniq()
    |> Enum.each(fn(device) ->
      Logger.info fn() -> "Starting #{inspect(device)}" end
      Supervisor.start_child(sup, worker(device, [pump_serial, local_timezone]))
    end)
  end

  def init(_) do
    supervise [], strategy: :one_for_one
  end
end

defmodule Pummpcomm.DriverSelector do
  # use GenServer
  use Agent

  require Logger

  alias SubgRfspy.{SPI, UART}
  alias RFM69.Device

  def start_link do
    Agent.start_link(fn -> nil end, name: __MODULE__)

    device_start_fns()
    |> Enum.find_value(&find_device/1)
  end

  def driver do
    Agent.get(__MODULE__, fn(name) -> name end)
  end

  defp find_device({name, start_fn}) do
    case start_fn.() do
      {:ok, pid} = val ->
        Logger.info fn() -> "#{inspect name} Found" end
        Process.register pid, :pump_driver
        Agent.update(__MODULE__, fn(_) -> name end)
        val
      _ ->
        Logger.info fn() -> "#{inspect name} Not Found" end
        false
    end
  end

  defp device_start_fns do
    %{
      SubgRfspy => fn() -> SPI.start_link("spidev0.0", 4) end,
      SubgRfspy => fn() -> UART.start_link("/dev/ttyAMA0") end,
      RFM69 =>     fn() -> Device.start_link("spidev0.0", 24, 23) end
    }
  end
end
