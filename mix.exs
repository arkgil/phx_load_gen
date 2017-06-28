defmodule PhxLoadGen.Mixfile do
  use Mix.Project

  def project do
    [app: :phx_load_gen,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {PhxLoadGen.Application, []}]
  end

  defp deps do
    [{:websocket_client, github: "sanmiguel/websocket_client", tag: "1.1.0"},
     {:poison, "~> 1.5.2"},
     {:phoenix_gen_socket_client, "~> 1.1.1"}]
  end
end
