defmodule PhxLoadGen.ClientSupervisor do
  @moduledoc false

  def start_link do
    import Supervisor.Spec, only: [worker: 2]

    children = [
      worker(PhxLoadGen.Client, [])
    ]

    opts = [strategy: :simple_one_for_one]
    Supervisor.start_link(children, opts)
  end
end
