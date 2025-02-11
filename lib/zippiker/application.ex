defmodule Zippiker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ZippikerWeb.Telemetry,
      Zippiker.Repo,
      {DNSCluster, query: Application.get_env(:zippiker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Zippiker.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Zippiker.Finch},
      # Start a worker by calling: Zippiker.Worker.start_link(arg)
      # {Zippiker.Worker, arg},
      # Start to serve requests, typically the last entry
      ZippikerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zippiker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ZippikerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
