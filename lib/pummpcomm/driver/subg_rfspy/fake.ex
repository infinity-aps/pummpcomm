defmodule Pummpcomm.Driver.SubgRfspy.Fake do
  use GenServer
  alias ExUnit.Assertions
  require Logger

  @genserver_timeout 60000

  def start_link(context_name) do
    File.mkdir_p("test/cassettes")
    record = System.get_env("RECORD_NEW") == "true"
    initial_state = case record do
      true ->
        {:ok, _} = Pummpcomm.Driver.SubgRfspy.UART.start_link
        %{record: true, interactions: [], context_name: context_name}
      false ->
        expected_interactions = File.stream!(cassette_filename(context_name)) |> CSV.decode! |> Enum.map(&(&1))
        %{record: false, interactions: [], remaining_interactions: expected_interactions}
    end

    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def write(data, timeout_ms) do
    GenServer.call(__MODULE__, {:write, data, timeout_ms}, @genserver_timeout)
  end

  def read(timeout_ms) do
    GenServer.call(__MODULE__, {:read, timeout_ms}, @genserver_timeout)
  end

  def interactions do
    GenServer.call(__MODULE__, :interactions, @genserver_timeout)
  end

  # GENSERVER LIFECYCLE

  def init(initial_state) do
    Process.flag :trap_exit, true
    {:ok, initial_state}
  end

  def terminate(_, %{record: true, interactions: interactions, context_name: context_name}) do
    file = File.open!(cassette_filename(context_name), [:write, :utf8])
    interactions |> Enum.reverse |> CSV.encode |> Enum.each(&IO.write(file, &1))
  end

  def terminate(_, %{interactions: expected_interactions}) do
    Assertions.assert expected_interactions, []
  end

  # PLAYBACK MODE

  def handle_call({:write, data, _timeout_ms}, _from, state = %{record: false}) do
    %{remaining_interactions: [["write", expected_data, response] | rest], interactions: interactions} = state
    new_interactions = [["write", expected_data, response] | interactions]
    {:ok, expected_data} = Base.decode16(expected_data)
    Assertions.assert expected_data, data
    new_state = %{state | interactions: new_interactions, remaining_interactions: rest}
    {:reply, String.to_atom(response), new_state}
  end

  def handle_call({:read, _timeout_ms}, _from, state = %{record: false}) do
    %{remaining_interactions: [["read", expected_data, response] | rest], interactions: interactions} = state
    new_interactions = [["read", expected_data, response] | interactions]
    {:ok, expected_data} = Base.decode16(expected_data)
    new_state = %{state | interactions: new_interactions, remaining_interactions: rest}
    {:reply, {String.to_atom(response), expected_data}, new_state}
  end

  # RECORD MODE

  def handle_call({:write, data, timeout_ms}, _from, state = %{record: true, interactions: interactions}) do
    response = Pummpcomm.Driver.SubgRfspy.UART.write(data, timeout_ms)
    interaction = ["write", Base.encode16(data), Atom.to_string(response)]
    state = %{state | interactions: [interaction | interactions]}
    {:reply, response, state}
  end

  def handle_call({:read, timeout_ms}, _from, state = %{record: true, interactions: interactions}) do
    {response, data} = Pummpcomm.Driver.SubgRfspy.UART.read(timeout_ms)
    Logger.debug "Received response from Real UART: {#{response}, #{data}}"
    interaction = ["read", Base.encode16(data), Atom.to_string(response)]
    state = %{state | interactions: [interaction | interactions]}
    {:reply, {response, data}, state}
  end

  def handle_call(:interactions, _from, state = %{interactions: interactions}) do
    {:reply, interactions |> Enum.reverse, state}
  end

  defp cassette_filename(context_name) do
    "test/cassettes/#{context_name |> Atom.to_string() |> String.replace(" ", "_")}.csv"
  end
end
