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
  use GenServer

  alias SubgRfspy.{SPI, UART}
  alias RFM69.Device

  def start_link do
    device_start_fns() |> Enum.find_value(fn(start_fn) -> {:ok, _} = start_fn.() end)
  end

  defp device_start_fns do
    [
    fn() -> SPI.start_link("spidev0.0", 4) end,
    fn() -> UART.start_link("/dev/ttyAMA0") end,
    fn() -> Device.start_link("spidev0.0", 24, 23) end
    ]
  end
end
