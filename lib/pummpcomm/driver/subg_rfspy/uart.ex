defmodule Pummpcomm.Driver.SubgRfspy.UART do
  require Logger
  use GenServer
  alias Pummpcomm.Driver.SerialFraming

  def start_link(device) do
    GenServer.start_link(__MODULE__, device, name: __MODULE__)
  end

  def init(device) do
    with {:ok, serial_pid} <- Nerves.UART.start_link,
         :ok <- Nerves.UART.open(serial_pid, device, speed: 19_200, active: false),
         :ok <- Nerves.UART.configure(serial_pid, framing: {SerialFraming, separator: <<0x00>>}),
         :ok <- Nerves.UART.flush(serial_pid) do

      {:ok, serial_pid}
    else
      error ->
        Logger.error fn -> "The UART failed to start: #{inspect(error)}" end
        {:error, "The UART failed to start"}
    end
  end

  def terminate(reason, serial_pid) do
    Logger.warn fn -> "Exiting, reason: #{inspect reason}" end
    Nerves.UART.close(serial_pid)
  end

  def write(data, timeout_ms) do
    GenServer.call(__MODULE__, {:write, data, timeout_ms}, genserver_timeout(timeout_ms))
  end

  def read(timeout_ms) do
    GenServer.call(__MODULE__, {:read, timeout_ms}, genserver_timeout(timeout_ms))
  end

  def handle_call({:write, data, timeout_ms}, _from, serial_pid) do
    {:reply, write_fully(data, timeout_ms, serial_pid), serial_pid}
  end

  def handle_call({:read, timeout_ms}, _from, serial_pid) do
    is_uart_running = "ps" |> System.cmd([]) |> elem(0) |> String.contains?("uart")
    if !is_uart_running do
      Logger.debug fn -> "UART port is not running!" end
    end
    {:reply, Nerves.UART.read(serial_pid, timeout_ms + 1_000), serial_pid}
  end

  defp write_fully(data, timeout_ms, serial_pid) do
    case Nerves.UART.write(serial_pid, data, timeout_ms) do
      :ok ->
        Nerves.UART.drain(serial_pid)
        Nerves.UART.flush(serial_pid, :receive)
      err -> err
    end
  end

  defp genserver_timeout(timeout_ms) do
    timeout_ms + 2_000
  end
end
