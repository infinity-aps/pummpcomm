defmodule Pummpcomm.Session.Pump do
  use GenServer
  require Logger
  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Command
  alias Pummpcomm.Session.Context
  alias Pummpcomm.Session.Response

  @genserver_timeout 60000

  def start_link do
    pump_serial = System.get_env("PUMP_SERIAL") || config(:pump_serial)
    {:ok, %{model_number: model_number}} = ensure_pump_awake(pump_serial)
    state = %{
      pump_serial: pump_serial,
      model_number: model_number
    }

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def read_history_page(page_number) do
    GenServer.call(__MODULE__, {:read_history_page, page_number}, @genserver_timeout)
  end

  def handle_call({:read_history_page, page_number}, _from, state = %{pump_serial: pump_serial}) do
    with {:ok, _} <- ensure_pump_awake(pump_serial),
         {:ok, context} <- state.pump_serial |> Command.read_history_page(page_number) |> PumpExecutor.execute(),
         response <- Response.get_data(context.response) do
      {:reply, response, state}
    else
      _ -> {:reply, {:error, "Read History Page Failed"}, state}
    end
  end

  defp ensure_pump_awake(pump_serial) do
    response = read_pump_model(pump_serial)
    case response do
      {:ok, _} -> response
      _ ->
        Logger.info "Sending power control command"
        Command.power_control(pump_serial) |> PumpExecutor.repeat_execute(500, 12000)
        read_pump_model(pump_serial)
    end
  end

  def read_pump_model(pump_serial) do
    case Command.read_pump_model(pump_serial) |> PumpExecutor.execute() do
      {:ok, %Context{response: response}} ->
        {:ok, Response.get_data(response)}
      other                                   ->
        other
    end
  end

  defp config(key) do
    Keyword.get(config(), key)
  end

  defp config do
    Application.get_env(:pummpcomm, Pummpcomm.Session.Pump)
  end
end
