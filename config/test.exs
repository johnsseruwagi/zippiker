import Config
config :zippiker, token_signing_secret: "HAIQtDWwXhxYc6/TiUc3rOFfisGisrZ1"
config :ash, disable_async?: true
config :ash, :missed_notifications, :ignore

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :zippiker, Zippiker.Repo,
  username: "postgres",
  password: "macbookpro2015",
  hostname: "localhost",
  database: "zippiker_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :zippiker, ZippikerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "bq5ighYVx2oMkWQuo6LthXPqiUnweeJaQDl2frHGWsS4SLa88K7Loo5A/y2Lwizh",
  server: false

# In test we don't send emails
config :zippiker, Zippiker.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
