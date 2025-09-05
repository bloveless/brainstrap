defmodule Brainstrap.Repo do
  use Ecto.Repo,
    otp_app: :brainstrap,
    adapter: Ecto.Adapters.Postgres
end
