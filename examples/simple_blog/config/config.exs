# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :simple_blog, SimpleBlog.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "BHmOT2LUbCvWBU6CJsNfU78/E3dGEpmR5HqTj6syHickv5CBNEX9lMk9ygZCn1xx",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: SimpleBlog.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Configures Dayron's RestRepo
config :simple_blog, SimpleBlog.RestRepo,
  url: "http://jsonplaceholder.typicode.com"

# Generators config
config :dayron, :generators,
  models_path: "web/models",
  models_test_path: "test/models"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
