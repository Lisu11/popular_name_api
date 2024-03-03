defmodule PopularNameApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PopularNameApiWeb.Telemetry,
      PopularNameApi.Repo,
      {DNSCluster, query: Application.get_env(:popular_name_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PopularNameApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PopularNameApi.Finch},
      # Start a worker by calling: PopularNameApi.Worker.start_link(arg)
      # {PopularNameApi.Worker, arg},
      # Start to serve requests, typically the last entry
      PopularNameApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PopularNameApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PopularNameApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
