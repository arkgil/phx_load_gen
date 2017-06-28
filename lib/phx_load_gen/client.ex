defmodule PhxLoadGen.Client do
  @moduledoc false

  alias Phoenix.Channels.GenSocketClient

  require Logger

  @behaviour GenSocketClient

  def start_link(ws_url, id, topic, send_interval, send_repeats) do
    GenSocketClient.start_link(__MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      {id, ws_url, topic, send_interval, send_repeats})
  end

  def init({id, url, topic, send_interval, send_repeats}) do
    {:connect, url, %{topic: topic, id: to_string(id),
                      send_interval: send_interval, send_repeats: send_repeats}}
  end

  def handle_connected(transport, %{topic: topic, id: id} = state) do
    Logger.info fn -> "[Client #{id}] connected" end
    GenSocketClient.join(transport, topic, %{user: id})
    Process.send_after self(), :send, state.send_interval
    {:ok, state}
  end

  def handle_disconnected(reason, %{id: id} = state) do
    Logger.info fn -> "[Client #{id}] disconnected: #{inspect reason}" end
    Process.send_after(self(), :reconnect, 1_000)
    {:ok, state}
  end

  def handle_joined(topic, _payload, _transport, %{id: id} = state) do
    Logger.info fn ->
      "[Client #{id}] joined the topic #{topic}"
    end
    {:ok, state}
  end

  def handle_join_error(topic, payload, _transport, %{id: id} = state) do
    Logger.error fn ->
      "[Client #{id}] could not join the topic #{topic}: #{inspect payload}"
    end
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, %{id: id} = state) do
    Logger.error fn ->
      "[Client #{id}] disconnected from the topic #{topic}: #{inspect payload}"
    end
    Process.send_after(self(), {:join, topic}, :timer.seconds(1))
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, %{id: id} = state) do
    Logger.debug fn ->
      "[Client #{id}] got event #{event} with payload #{inspect payload} " <>
        "on topic: #{topic}"
    end
    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, %{id: id} = state) do
    Logger.debug fn ->
      "[Client #{id}] got reply on topic #{topic}: #{inspect payload}"
    end
    {:ok, state}
  end

  def handle_info(:reconnect, _transport, %{id: id} = state) do
    Logger.info fn ->
      "[Client #{id}] reconnecting"
    end
    {:connect, state}
  end
  def handle_info(:send, _transport, %{send_repeats: 0} = state) do
    Logger.info "Stopping"
    {:stop, :normal, state}
  end
  def handle_info(:send, transport, %{send_repeats: send_repeats} = state) do
    GenSocketClient.push transport, state.topic, "new:msg",
      %{user: state.id, body: "Hello!"}
    Process.send_after self(), :send, state.send_interval
    {:ok, %{state | send_repeats: send_repeats - 1}}
  end

end
