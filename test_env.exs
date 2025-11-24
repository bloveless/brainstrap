#!/usr/bin/env elixir

# Load the application
Application.put_env(:brainstrap, :ecto_repos, [Brainstrap.Repo])

# Load .env file
Dotenvy.source(".env")

# Check if the environment variable is loaded
api_key = System.get_env("OPENROUTER_API_KEY")

if api_key do
  IO.puts("✓ OPENROUTER_API_KEY is loaded: #{String.slice(api_key, 0, 10)}...")
else
  IO.puts("✗ OPENROUTER_API_KEY is not loaded")
end

# Check application config
app_config = Application.get_env(:brainstrap, :openrouter_api_key)

if app_config do
  IO.puts("✓ Application config is set: #{String.slice(app_config, 0, 10)}...")
else
  IO.puts("✗ Application config is not set")
end
