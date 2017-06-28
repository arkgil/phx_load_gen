defmodule PhxLoadGen do
  @moduledoc false

  def start(url, start_id, end_id, topic, send_interval, send_repeats) do
    case Supervisor.start_child(PhxLoadGen.Supervisor, []) do
      {:ok, pid} ->
        for id <- start_id..end_id do
          {:ok, _} = Supervisor.start_child(pid,
            [url, id, topic, send_interval, send_repeats])
        end
      e ->
        e
    end
  end

  def stop(pid) do
    Supervisor.stop(pid)
  end
end
