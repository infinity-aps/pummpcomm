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

  alias Pummpcomm.PumpModel
  alias Pummpcomm.Session.PumpExecutor
  alias Pummpcomm.Session.Exchange.GetCurrentCgmPage
  alias Pummpcomm.Session.Exchange.ReadBatteryStatus
  alias Pummpcomm.Session.Exchange.ReadBgTargets
  alias Pummpcomm.Session.Exchange.ReadCarbRatios
  alias Pummpcomm.Session.Exchange.ReadCgmPage
  alias Pummpcomm.Session.Exchange.ReadHistoryPage
  alias Pummpcomm.Session.Exchange.ReadInsulinSensitivities
  alias Pummpcomm.Session.Exchange.ReadPumpStatus
  alias Pummpcomm.Session.Exchange.ReadRemainingInsulin
  alias Pummpcomm.Session.Exchange.ReadSettings
  alias Pummpcomm.Session.Exchange.ReadTempBasal
  alias Pummpcomm.Session.Exchange.ReadTime
  alias Pummpcomm.Session.Exchange.SetTempBasal
  alias Pummpcomm.Session.Exchange.WriteCgmTimestamp

  @timeout 60_000

  def start_link(pump_serial) do
    state = %{
      pump_serial: pump_serial,
      model_number: nil,
      initialized: false
    }

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get_current_cgm_page,           do: GenServer.call(__MODULE__, {:get_current_cgm_page},           @timeout)
  def read_battery_status,            do: GenServer.call(__MODULE__, {:read_battery_status},            @timeout)
  def read_bg_targets,                do: GenServer.call(__MODULE__, {:read_bg_targets},                @timeout)
  def read_carb_ratios,               do: GenServer.call(__MODULE__, {:read_carb_ratios},               @timeout)
  def read_cgm_page(page_number),     do: GenServer.call(__MODULE__, {:read_cgm_page, page_number},     @timeout)
  def read_history_page(page_number), do: GenServer.call(__MODULE__, {:read_history_page, page_number}, @timeout)
  def read_insulin_sensitivities,     do: GenServer.call(__MODULE__, {:read_insulin_sensitivities},     @timeout)
  def read_pump_status,               do: GenServer.call(__MODULE__, {:read_pump_status},               @timeout)
  def read_remaining_insulin,         do: GenServer.call(__MODULE__, {:read_remaining_insulin},         @timeout)
  def read_temp_basal,                do: GenServer.call(__MODULE__, {:read_temp_basal},                @timeout)
  def read_time,                      do: GenServer.call(__MODULE__, {:read_time},                      @timeout)

  def set_temp_basal(options = [units_per_hour: _, duration_minutes: _, type: :absolute]) do
    GenServer.call(__MODULE__, {:set_temp_basal, options}, @timeout)
  end
  def write_cgm_timestamp,            do: GenServer.call(__MODULE__, {:write_cgm_timestamp},            @timeout)

  def handle_call(call_params, from, state = %{initialized: false}) do
    case PumpExecutor.ensure_pump_awake(state.pump_serial) do
      {:ok, %{model_number: model_number}} ->
        handle_call(call_params, from, %{state | initialized: true, model_number: model_number})
      _ ->
        {:reply, {:error, "Pump did not respond to initial communication"}, state}
    end
  end

  def handle_call(pump_call, _from, state) do
    with {:ok, _} <- PumpExecutor.ensure_pump_awake(state.pump_serial),
         {:reply, response, state} <- make_pump_call(pump_call, state) do
      {:reply, response, state}
    else
      _ -> {:reply, {:error, "#{Atom.to_string(elem(pump_call, 0))} Failed"}, state}
    end
  end

  def make_pump_call({:get_current_cgm_page}, state) do
    with {:ok, context} <- state.pump_serial |> GetCurrentCgmPage.make() |> PumpExecutor.execute(),
         response       <- GetCurrentCgmPage.decode(context.response) do
      {:reply, response, state}
    end
  end

  def make_pump_call({:read_battery_status}, state) do
    with {:ok, context} <- state.pump_serial |> ReadBatteryStatus.make() |> PumpExecutor.execute(),
         response       <- ReadBatteryStatus.decode(context.response) do
      {:reply, response, state}
    end
  end

  def make_pump_call({:read_bg_targets}, state) do
    with {:ok, context} <- state.pump_serial |> ReadBgTargets.make() |> PumpExecutor.execute(),
         response       <- ReadBgTargets.decode(context.response) do
      {:reply, response, state}
    end
  end

  def make_pump_call({:read_carb_ratios}, state) do
    with {:ok, context} <- state.pump_serial |> ReadCarbRatios.make() |> PumpExecutor.execute(),
         response       <- ReadCarbRatios.decode(context.response, state.model_number) do
      {:reply, response, state}
    end
  end

  def make_pump_call({:read_cgm_page, page_number}, state) do
    with {:ok, context} <- state.pump_serial |> ReadCgmPage.make(page_number) |> PumpExecutor.execute(),
         response       <- ReadCgmPage.decode(context.response) do
      {:reply, response, state}
    end
  end

  def make_pump_call({:read_history_page, page_number}, state) do
    with {:ok, context} <- state.pump_serial |> ReadHistoryPage.make(page_number) |> PumpExecutor.execute(),
         response       <- ReadHistoryPage.decode(context.response, state.model_number) do
      {:reply, response, state}
    end
  end

  def make_pump_call({:read_insulin_sensitivities}, state) do
    with {:ok, context} <- state.pump_serial |> ReadInsulinSensitivities.make() |> PumpExecutor.execute(),
         response       <- ReadInsulinSensitivities.decode(context.response) do
      {:reply, response, state}
    end
  end

  def make_pump_call({:read_pump_status}, state) do
    with {:ok, context} <- state.pump_serial |> ReadPumpStatus.make() |> PumpExecutor.execute(),
         pump_status    <- ReadPumpStatus.decode(context.response) do
      {:reply, {:ok, pump_status}, state}
    end
  end

  def make_pump_call({:read_remaining_insulin}, state) do
    with {:ok, context}                        <- state.pump_serial |> ReadRemainingInsulin.make() |> PumpExecutor.execute(),
         %{strokes_per_unit: strokes_per_unit} <- PumpModel.pump_options(state.model_number),
         result                                <- ReadRemainingInsulin.decode(context.response, strokes_per_unit) do
      {:reply, {:ok, result}, state}
    end
  end

  def make_pump_call({:read_settings}, state) do
    with {:ok, context} <- state.pump_serial |> ReadSettings.make() |> PumpExecutor.execute(),
         pump_status    <- ReadSettings.decode(context.response) do
      {:reply, {:ok, pump_status}, state}
    end
  end

  def make_pump_call({:read_temp_basal}, state) do
    with {:ok, context} <- state.pump_serial |> ReadTempBasal.make() |> PumpExecutor.execute(),
         temp_basal     <- ReadTempBasal.decode(context.response) do
      {:reply, {:ok, temp_basal}, state}
    end
  end

  def make_pump_call({:read_time}, state) do
    with {:ok, context} <- state.pump_serial |> ReadTime.make() |> PumpExecutor.execute(),
         parsed_date    <- ReadTime.decode(context.response) do
      {:reply, {:ok, parsed_date}, state}
    end
  end

  def make_pump_call({:set_temp_basal, options}, state) do
    with {:ok, context} <- state.pump_serial |> SetTempBasal.make(options) |> PumpExecutor.execute(),
         :ok            <- SetTempBasal.decode(context.response),
         {:ok, context} <- state.pump_serial |> ReadTempBasal.make() |> PumpExecutor.execute(),
         temp_basal     <- ReadTempBasal.decode(context.response) do
      {:reply, {:ok, temp_basal}, state}
    end
  end

  def make_pump_call({:write_cgm_timestamp}, state) do
    with {:ok, %{received_ack: true}} <- state.pump_serial |> WriteCgmTimestamp.make() |> PumpExecutor.execute() do
      {:reply, :ok, state}
    end
  end
end
