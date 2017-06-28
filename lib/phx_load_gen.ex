defmodule PhxLoadGen do
  @moduledoc """
  Generate load on Phoenix channels!
  """

  @doc """
  Start batch of Phoenix clients

  * `url` is a websocket Phoenix endpoint URL (usually ws://HOST:PORT/socket/websocket)
  * `start_id` and `end_id` is a range of identifiers assigned to clients
  * `topic` the topic clients should join (when used with https://github.com/arkgil/phoenix_chat_example
    it should be `"rooms:lobby"`)
  * `send_interval` how often clients should send messages
  * `send_repeats` how many messages will be send

  On success it'll return `{:ok, pid}`. Returned pid can be passed to `stop/1`
  to stop the clients.
  """
  def start(url, start_id, end_id, topic, send_interval, send_repeats) do
    case Supervisor.start_child(PhxLoadGen.Supervisor, []) do
      {:ok, pid} ->
        for id <- start_id..end_id do
          {:ok, _} = Supervisor.start_child(pid,
            [url, id, topic, send_interval, send_repeats])
        end
        {:ok, pid}
      e ->
        e
    end
  end

  def stop(pid) do
    Supervisor.stop(pid)
  end
end
