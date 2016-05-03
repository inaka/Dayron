defmodule Dayron.Repo do
  @moduledoc """
  Defines a rest repository.

  A repository maps to an underlying http client, which send requests to a
  remote server. Currently the only available client is HTTPoison with hackney.

  When used, the repository expects the `:otp_app` as option.
  The `:otp_app` should point to an OTP application that has
  the repository configuration. For example, the repository:

      defmodule MyApp.Dayron do
        use Dayron.Repo, otp_app: :my_app
      end

  Could be configured with:

      config :my_app, MyApp.Dayron,
        url: "https://api.example.com",
        headers: [access_token: "token"]

  The available configuration is:

    * `:url` - an URL that specifies the server api address
    * `:headers` - a keywords list with values to be sent on each request header

  URLs also support `{:system, "KEY"}` to be given, telling Dayron to load
  the configuration from the system environment instead:

      config :my_app, Dayron,
        url: {:system, "API_URL"}

  """
  @cannot_call_directly_error """
  Cannot call Dayron.Repo directly. Instead implement your own Repo module
  with: use Dayron.Repo, otp_app: :my_app
  """

  alias Dayron.Model
  alias Dayron.Config

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Dayron.Repo

      {otp_app, adapter, config} = Config.parse(__MODULE__, opts)
      @otp_app otp_app
      @adapter adapter
      @config  config

      def get(model, id, opts \\ []) do
        Repo.get(@adapter, model, id, opts, @config)
      end

      # TBD
      def all(model, opts \\ []), do: nil

      def get!(model, id, opts \\ []), do: nil

      def insert(model, opts \\ []), do: nil

      def update(model, opts \\ []), do: nil

      def delete(model, opts \\ []), do: nil

      def insert!(model, opts \\ []), do: nil

      def update!(model, opts \\ []), do: nil

      def delete!(model, opts \\ []), do: nil
    end
  end

  def get(_module, _id, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  def get(adapter, model, id, opts, config) do
    url = Config.get_request_url(config, model, id: id)
    headers = Config.get_headers(config)
    case adapter.get(url, headers, opts) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Model.from_json(model, body)
      {:ok, %HTTPoison.Response{status_code: 404}} -> nil
      # TODO: log all requests, specially error messages
      _error -> nil
    end
  end
end
