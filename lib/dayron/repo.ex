defmodule Dayron.Repo do
  @moduledoc """
  Defines a rest repository.

  A repository maps to an underlying http client, which send requests to a
  remote server. Currently the only available client is HTTPoison with hackney.

  When used, the repository expects the `:otp_app` as option.
  The `:otp_app` should point to an OTP application that has
  the repository configuration. For example, the repository:

      defmodule MyApp.RestRepo do
        use Dayron.Repo, otp_app: :my_app
      end

  Could be configured with:

      config :my_app, MyApp.RestRepo,
        url: "https://api.example.com",
        headers: [access_token: "token"]

  The available configuration is:

    * `:url` - an URL that specifies the server api address
    * `:adapter` - a module implementing Dayron.Adapter behaviour, default is
    HTTPoisonAdapter
    * `:headers` - a keywords list with values to be sent on each request header

  URLs also support `{:system, "KEY"}` to be given, telling Dayron to load
  the configuration from the system environment instead:

      config :my_app, MyApp.RestRepo,
        url: {:system, "API_URL"}

  """
  @cannot_call_directly_error """
  Cannot call Dayron.Repo directly. Instead implement your own Repo module
  with: use Dayron.Repo, otp_app: :my_app
  """

  alias Dayron.Model
  alias Dayron.Config
  alias Dayron.ResponseLogger

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

      def get!(model, id, opts \\ []) do
        Repo.get!(@adapter, model, id, opts, @config)
      end

      def all(model, opts \\ []) do
        Repo.all(@adapter, model, opts, @config)
      end

      def insert(model, data, opts \\ []) do
        Repo.insert(@adapter, model, data, opts, @config)
      end

      def insert!(model, data, opts \\ []) do
        Repo.insert!(@adapter, model, data, opts, @config)
      end

      # TBD
      def update(model, opts \\ []), do: nil

      def delete(model, opts \\ []), do: nil

      def update!(model, opts \\ []), do: nil

      def delete!(model, opts \\ []), do: nil
    end
  end

  @doc """
  Fetches a single model from the external api, building the request url based
  on the given model and id.

  Returns `nil` if no result was found or server reponds with an error.
  Returns a model struct with response values if valid.

  Options are sent directly to the selected adapter. See `Dayron.Adapter.get/3`
  for avaliable options.

  ## Possible Exceptions
    * `Dayron.ServerError` - if server responds with a 500 internal error.
    * `Dayron.ClientError` - for any error detected in client side, such as
    timeout or connection errors.
  """
  def get(_module, _id, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc """
  Similar to `get/3` but raises `Dayron.NoResultsError` if no resource is returned in the server response.
  """
  def get!(_module, _id, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc """
  Fetches a list of models from the external api, building the request url
  based on the given model.

  Returns an empty list if no result was found or server reponds with an error.
  Returns a list of model structs if response is valid.

  Options are sent directly to the selected adapter. See `Dayron.Adapter.get/3`
  for avaliable options.

  ## Possible Exceptions
    * `Dayron.ServerError` - if server responds with a 500 internal error.
    * `Dayron.ClientError` - for any error detected in client side, such as
    timeout or connection errors.
  """
  def all(_module, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc """
  Inserts a model or an `Ecto.Changeset`.

  In case a model is given, the model is converted into a changeset
  with all model non-virtual fields as part of the changeset.
  This conversion is done by calling `Ecto.Changeset.change/2` directly.

  In case a changeset is given, the changes in the changeset are
  merged with the model fields, and all of them are sent to the
  database.

  Options are sent directly to the selected adapter.
  See Dayron.Adapter.insert/3 for avaliable options.

  ## Possible Exceptions
    * `Dayron.ServerError` - if server responds with a 500 internal error.
    * `Dayron.ClientError` - for any error detected in client side, such as
    timeout or connection errors.

  ## Example

      case RestRepo.insert %User{name: "Dayse"} do
        {:ok, model}        -> # Inserted with success
        {:error, changeset} -> # Something went wrong
      end

  """
  def insert(_module, _data, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc """
  Similar to `insert/3` but raises a `Dayron.ValidationError` if server responds with a 422 unprocessable entity.
  """
  def insert!(_module, _data, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc false
  def get(adapter, model, id, opts, config) do
    {url, response} = get_response(adapter, model, [id: id], opts, config)
    case response do
      %HTTPoison.Response{status_code: 200, body: body} ->
        Model.from_json(model, body)
      %HTTPoison.Response{status_code: code} when code >= 300 and code < 500 ->
        nil
      %HTTPoison.Response{status_code: 500, body: body} ->
        raise Dayron.ServerError, method: "GET", url: url, body: body
      %HTTPoison.Error{reason: reason} -> :ok
        raise Dayron.ClientError, method: "GET", url: url, reason: reason
    end
  end

  @doc false
  def get!(adapter, model, id, opts, config) do
    case get(adapter, model, id, opts, config) do
      nil -> 
        url = Config.get_request_url(config, model, [id: id])
        raise Dayron.NoResultsError, method: "GET", url: url
      model -> model
    end
  end

  @doc false
  def all(adapter, model, opts, config) do
    {url, response} = get_response(adapter, model, [], opts, config)
    case response do
      %HTTPoison.Response{status_code: 200, body: body} ->
        Model.from_json_list(model, body)
      %HTTPoison.Response{status_code: code, body: body} when code >= 300 ->
        raise Dayron.ServerError, method: "GET", url: url, body: body
      %HTTPoison.Error{reason: reason} ->
        raise Dayron.ClientError, method: "GET", url: url, reason: reason
    end
  end

  @doc false
  def insert(adapter, model, data, opts, config) do
    {url, response} = post_response(adapter, model, data, opts, config)
    case response do
      %HTTPoison.Response{status_code: 201, body: body} ->
        {:ok, Model.from_json(model, body)}
      %HTTPoison.Response{status_code: 422, body: body} ->
        {:error, %{method: "POST", url: url, response: body}}
      %HTTPoison.Response{status_code: code, body: body} when code >= 500 ->
        raise Dayron.ServerError, method: "POST", url: url, body: body
      %HTTPoison.Error{reason: reason} ->
        raise Dayron.ClientError, method: "POST", url: url, reason: reason
    end
  end

  def insert!(adapter, model, data, opts, config) do
    case insert(adapter, model, data, opts, config) do
      {:ok, model} -> {:ok, model}
      {:error, error} -> raise Dayron.ValidationError, Map.to_list(error)
    end
  end

  defp get_response(adapter, model, url_opts, request_opts, config) do
    url = Config.get_request_url(config, model, url_opts)
    headers = Config.get_headers(config)
    {_, response} = adapter.get(url, headers, request_opts)
    if Config.log_responses?(config) do
      ResponseLogger.log("GET", url, response)
    end
    {url, response}
  end

  defp post_response(adapter, model, data, request_opts, config) do
    url = Config.get_request_url(config, model, [])
    headers = Config.get_headers(config)
    {_, response} = adapter.post(url, data, headers, request_opts)
    if Config.log_responses?(config) do
      request_details = [body: model]
      ResponseLogger.log("POST", url, response, request_details)
    end
    {url, response}
  end
end
