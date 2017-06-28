defmodule PhxLoadGen.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(PhxLoadGen.ClientSupervisor, [])
    ]

    opts = [strategy: :simple_one_for_one, name: PhxLoadGen.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
