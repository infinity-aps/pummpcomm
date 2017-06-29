defmodule Pummpcomm.Driver.SubgRfspy.Fake do
  use GenServer
  require Logger

  @genserver_timeout 60000

  def start_link(context_name, record \\ false, device \\ nil) do
    IO.puts "#{context_name}, record = #{inspect(record)}, device = #{inspect(device)}"
    initial_state = case record do
      true ->
        {:ok, _} = Pummpcomm.Driver.SubgRfspy.UART.start_link(device)
        %{record: true, interactions: []}
      false ->
        IO.puts "Not ready for playback quite yet"
        %{record: false, interactions: []}
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
    GenServer.call(__MODULE__, {:interactions}, @genserver_timeout)
  end

  def handle_call({:write, _data, _timeout_ms}, _from, state = %{record: false}) do
    Logger.error "Not ready for playback mode"
    {:reply, :error, state}
  end

  def handle_call({:write, data, timeout_ms}, _from, state = %{record: true, interactions: interactions}) do
    response = Pummpcomm.Driver.SubgRfspy.UART.write(data, timeout_ms)
    Logger.debug "Recording write data: #{Base.encode16(data)}, response: #{inspect(response)}"
    state = %{state | interactions: [{:write, response, data} | interactions] |> Enum.reverse}
    {:reply, response, state}
  end

  def handle_call({:read, _timeout_ms}, _from, state = %{record: false}) do
    Logger.error "Not ready for playback mode"
    {:reply, :error, state}
  end

  def handle_call({:read, timeout_ms}, _from, state = %{record: true, interactions: interactions}) do
    response = Pummpcomm.Driver.SubgRfspy.UART.read(timeout_ms)
    Logger.debug "Recording read data: #{inspect(response)}"
    state = %{state | interactions: [{:read, response} | interactions] |> Enum.reverse}
    {:reply, response, state}
  end

  def handle_call({:interactions}, _from, state) do
    {:reply, format_interactions(state.interactions, []), state}
  end

  defp format_interactions([], formatted), do: formatted |> Enum.reverse
  defp format_interactions([interaction | rest], formatted) do
    formatted_interaction = case interaction do
      {:read, {:ok, data}} -> {:read, {:ok, Base.encode16(data)}}
      {:read, _} -> interaction
      {:write, _, _} -> put_elem(interaction, 2, elem(interaction, 2) |> Base.encode16())
    end
    format_interactions(rest, [formatted_interaction | formatted])
  end
end
