defmodule UartCaseTemplate do
  use ExUnit.CaseTemplate

  alias Pummpcomm.Driver.SubgRfspy.Fake
  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.ReadPumpModel
  alias Pummpcomm.Session.Exchange.PowerControl

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}, 5000
  end

  defp ensure_pump_awake(pump_serial) do
    case %{ReadPumpModel.make(pump_serial) | retries: 0} |> PumpExecutor.execute() do
      {:ok, _} -> nil
      _ -> pump_serial |> PowerControl.make() |> PumpExecutor.repeat_execute(500, 12_000)
    end
  end

  setup(context) do
    {:ok, pid} = Fake.start_link(context[:test])
    on_exit(fn() -> assert_down(pid) end)

    pump_serial = pump_serial(context)
    ensure_pump_awake(pump_serial)
    %{pump_serial: pump_serial}
  end

  defp pump_serial(context) do
    record = System.get_env("RECORD_CASSETTE") || "false"
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
