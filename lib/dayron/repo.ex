defmodule Dayron.Repo do
  @moduledoc """
  Defines a rest repository.

<<<<<<< HEAD
  A repository maps to an underlying http client, which send requests to a
  remote server. Currently the only available client is HTTPoison with hackney.
=======
  A repository maps to an underlying http client, which send requests to a remote server. Currently the only available client is HTTPoison with hackney.
>>>>>>> extracting code from a working project, renaming to dayron

  When used, the repository expects the `:otp_app` as option.
  The `:otp_app` should point to an OTP application that has
  the repository configuration. For example, the repository:

      defmodule MyApp.Dayron do
        use Dayron.Repo, otp_app: :my_app
      end

  Could be configured with:

      config :my_app, Dayron,
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

  alias Dayron.Client
  alias Dayron.Model
  alias Dayron.Config

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do

      {otp_app, config} = Config.parse(__MODULE__, opts)
      @otp_app otp_app
      @config  config

      def get(model, id, opts \\ []) do
        Client.start
        url = request_url(model, id: id)
        case Client.get(url, headers, opts) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            Model.from_json(model, body)
          {:ok, %HTTPoison.Response{status_code: 404}} -> nil
          # TODO: log all requests, specially error messages
          _error -> nil
        end
      end

      # config accessors
      defp request_url(model, opts) do
        @config[:url] <> Model.url_for(model, opts)
      end

      defp headers do
        Keyword.get(@config, :headers, [])
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
end
