defmodule Pummpcomm.Session.Pump do
  @moduledoc """
  This GenServer represents a logical pump session and wraps the commands and responses needed in order to communicate
  with a pump so that execution happens as effortlessly as possible (including listening for silence, waking the pump,
  and retries). The serial number of the pump is all that is needed to initialize the GenServer, and it will query and
  store the model number upon the first interaction with the insulin pump.

  Underneath this GenServer, Pummpcomm.Session.Pump delegates the nitty gritty details to
  Pummpcomm.Session.PumpExecutor.
  """

  use GenServer
  require Logger
  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Context

  alias Pummpcomm.Session.Exchange.GetCurrentCgmPage
  alias Pummpcomm.Session.Exchange.PowerControl
  alias Pummpcomm.Session.Exchange.ReadCgmPage
  alias Pummpcomm.Session.Exchange.ReadHistoryPage
  alias Pummpcomm.Session.Exchange.ReadPumpModel
  alias Pummpcomm.Session.Exchange.ReadTempBasal
  alias Pummpcomm.Session.Exchange.ReadTime
  alias Pummpcomm.Session.Exchange.WriteCgmTimestamp

  @genserver_timeout 60_000

  def start_link(pump_serial) do
    state = %{
      pump_serial: pump_serial,
      model_number: nil,
      initialized: false
    }

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get_current_cgm_page do
    GenServer.call(__MODULE__, {:get_current_cgm_page}, @genserver_timeout)
  end

  def read_cgm_page(page_number) do
    GenServer.call(__MODULE__, {:read_cgm_page, page_number}, @genserver_timeout)
  end

  def write_cgm_timestamp do
    GenServer.call(__MODULE__, {:write_cgm_timestamp}, @genserver_timeout)
  end

  def read_history_page(page_number) do
    GenServer.call(__MODULE__, {:read_history_page, page_number}, @genserver_timeout)
  end

  def read_time do
    GenServer.call(__MODULE__, {:read_time}, @genserver_timeout)
  end

  def read_temp_basal do
    GenServer.call(__MODULE__, {:read_temp_basal}, @genserver_timeout)
  end

  def handle_call(call_params, from, state = %{initialized: false, pump_serial: pump_serial}) do
    case ensure_pump_awake(pump_serial) do
      {:ok, %{model_number: model_number}} ->
        handle_call(call_params, from, %{state | initialized: true, model_number: model_number})
      _ ->
        {:reply, {:error, "Pump did not respond to initial communication"}, state}
    end
  end

  def handle_call({:get_current_cgm_page}, _from, state = %{pump_serial: pump_serial}) do
    with {:ok, _} <- ensure_pump_awake(pump_serial),
         {:ok, context} <- state.pump_serial |> GetCurrentCgmPage.make() |> PumpExecutor.execute(),
           response <- GetCurrentCgmPage.decode(context.response) do
      {:reply, response, state}
    else
      _ -> {:reply, {:error, "Get Current CGM Page Failed"}, state}
    end
  end

  def handle_call({:read_cgm_page, page_number}, _from, state = %{pump_serial: pump_serial}) do
    with {:ok, _} <- ensure_pump_awake(pump_serial),
         {:ok, context} <- state.pump_serial |> ReadCgmPage.make(page_number) |> PumpExecutor.execute(),
           response <- ReadCgmPage.decode(context.response) do
      {:reply, response, state}
    else
      _ -> {:reply, {:error, "Read CGM Page Failed"}, state}
    end
  end

  def handle_call({:write_cgm_timestamp}, _from, state = %{pump_serial: pump_serial}) do
    with {:ok, _} <- ensure_pump_awake(pump_serial),
         {:ok, %{received_ack: true}} <- state.pump_serial |> WriteCgmTimestamp.make() |> PumpExecutor.execute() do
      {:reply, :ok, state}
    else
      _ -> {:reply, {:error, "Write CGM Timestamp Failed"}, state}
    end
  end

  def handle_call({:read_history_page, page_number}, _from, state = %{pump_serial: pump_serial, model_number: model_number}) do
    with {:ok, _} <- ensure_pump_awake(pump_serial),
         {:ok, context} <- state.pump_serial |> ReadHistoryPage.make(page_number) |> PumpExecutor.execute(),
         response <- ReadHistoryPage.decode(context.response, model_number) do
      {:reply, response, state}
    else
      _ -> {:reply, {:error, "Read History Page Failed"}, state}
    end
  end

  def handle_call({:read_time}, _from, state = %{pump_serial: pump_serial}) do
    with {:ok, _} <- ensure_pump_awake(pump_serial),
         {:ok, context} <- state.pump_serial |> ReadTime.make() |> PumpExecutor.execute(),
         parsed_date <- ReadTime.decode(context.response) do
      {:reply, {:ok, parsed_date}, state}
    else
      _ -> {:reply, {:error, "Read Time Failed"}, state}
    end
  end

  def handle_call({:read_temp_basal}, _from, state = %{pump_serial: pump_serial}) do
    with {:ok, _} <- ensure_pump_awake(pump_serial),
         {:ok, context} <- state.pump_serial |> ReadTempBasal.make() |> PumpExecutor.execute(),
         temp_basal <- ReadTempBasal.decode(context.response) do
      {:reply, {:ok, temp_basal}, state}
    else
      _ -> {:reply, {:error, "Read Temp Basal Failed"}, state}
    end
  end

  defp ensure_pump_awake(pump_serial) do
    response = read_pump_model(pump_serial)
    case response do
      {:ok, _} -> response
      _ ->
        Logger.info fn -> "Waking pump" end
        pump_serial |> PowerControl.make() |> PumpExecutor.repeat_execute(500, 12_000)
        read_pump_model(pump_serial)
    end
  end

  def read_pump_model(pump_serial) do
    PumpExecutor.wait_for_silence()
    case %{ReadPumpModel.make(pump_serial) | retries: 0} |> PumpExecutor.execute() do
      {:ok, %Context{response: response}} -> {:ok, ReadPumpModel.decode(response)}
      other                               -> other
    end
  end
end
