defmodule PopularNameApi.Repo do
  use Ecto.Repo,
    otp_app: :popular_name_api,
    adapter: Ecto.Adapters.Postgres
end
