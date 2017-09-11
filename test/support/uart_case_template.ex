defmodule UartCaseTemplate do
  use ExUnit.CaseTemplate

  alias SubgRfspy.UARTProxy
  alias Pummpcomm.Session.PumpExecutor

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}, 5000
  end

  setup(context) do
    record = System.get_env("RECORD_CASSETTE") || "false"

    {:ok, pid} = UARTProxy.start_link(context[:test])
    on_exit(fn() -> assert_down(pid) end)

    pump_serial = pump_serial(context, record)

    if record == "true" do
      PumpExecutor.ensure_pump_awake(pump_serial)
    end

    UARTProxy.record
    %{pump_serial: pump_serial}
  end

  defp pump_serial(context, record) do
    case record do
      "true" ->
        ps = System.get_env("PUMP_SERIAL")
        IO.write(File.open!(pump_serial_filename(context[:test]), [:write, :utf8]), ps)
        ps
      _ ->
        File.read!(pump_serial_filename(context[:test]))
    end
  end

  defp pump_serial_filename(context_name) do
    "test/cassettes/#{context_name |> Atom.to_string() |> String.replace(" ", "_")}.pump_serial.txt"
  end
end
