defmodule Pummpcomm.Driver.SubgRfspy.UART do
  @moduledoc """
  This GenServer provides the most basic read and write operations to communicate with a wireless chip running
  subg_rfspy firmware (https://github.com/ps2/subg_rfspy) over a UART. It is a thin wrapper around Nerves.UART
  to isolate the Pummpcomm.Driver.SubgRfspy module from UART specific details and serial device IO.
  """

  require Logger
  use GenServer
  alias Pummpcomm.Driver.SerialFraming
  alias Nerves.UART

  def start_link(device) do
    GenServer.start_link(__MODULE__, device, name: __MODULE__)
  end

  def init(device) do
    with {:ok, serial_pid} <- UART.start_link,
         :ok <- UART.open(serial_pid, device, speed: 19_200, active: false),
         :ok <- UART.configure(serial_pid, framing: {SerialFraming, separator: <<0x00>>}),
         :ok <- UART.flush(serial_pid) do

      {:ok, serial_pid}
    else
      error ->
        Logger.error fn -> "The UART failed to start: #{inspect(error)}" end
        {:error, "The UART failed to start"}
    end
  end

  def terminate(reason, serial_pid) do
    Logger.warn fn -> "Exiting, reason: #{inspect reason}" end
    UART.close(serial_pid)
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
    # is_uart_running = "ps" |> System.cmd([]) |> elem(0) |> String.contains?("uart")
    # if !is_uart_running do
    #   Logger.debug fn -> "UART port is not running!" end
    # end
    {:reply, UART.read(serial_pid, timeout_ms + 1_000), serial_pid}
  end

  defp write_fully(data, timeout_ms, serial_pid) do
    case UART.write(serial_pid, data, timeout_ms) do
      :ok ->
        UART.drain(serial_pid)
        UART.flush(serial_pid, :receive)
      err -> err
    end
  end

  defp genserver_timeout(timeout_ms) do
    timeout_ms + 2_000
  end
end
