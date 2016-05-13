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
  alias Dayron.Request
  alias Dayron.Response
  
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Dayron.Repo

      {otp_app, adapter, logger, config} = Config.parse(__MODULE__, opts)
      @otp_app otp_app
      @adapter adapter
      @logger  logger
      @config  config

      def get(model, id, opts \\ []) do
        Repo.get(@adapter, model, [id: id, options: opts], @logger, @config)
      end

      def get!(model, id, opts \\ []) do
        Repo.get!(@adapter, model, [id: id, options: opts], @logger, @config)
      end

      def all(model, opts \\ []) do
        Repo.all(@adapter, model, [options: opts], @logger, @config)
      end

      def insert(model, data, opts \\ []) do
        request_data = [body: data, options: opts]
        Repo.insert(@adapter, model, request_data, @logger, @config)
      end

      def insert!(model, data, opts \\ []) do
        request_data = [body: data, options: opts]
        Repo.insert!(@adapter, model, request_data, @logger, @config)
      end

      def update(model, id, data, opts \\ []) do
        request_data = [id: id, body: data, options: opts]
        Repo.update(@adapter, model, request_data, @logger, @config)
      end

      def update!(model, id, data, opts \\ []) do
        request_data = [id: id, body: data, options: opts]
        Repo.update!(@adapter, model, request_data, @logger, @config)
      end

      def delete(model, id, opts \\ []) do
        request_data = [id: id, options: opts]
        Repo.delete(@adapter, model, request_data, @logger, @config)
      end

      def delete!(model, id, opts \\ []) do
        request_data = [id: id, options: opts]
        Repo.delete!(@adapter, model, request_data, @logger, @config)
      end
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
  Similar to `get/3` but raises `Dayron.NoResultsError` if no resource is
  returned in the server response.
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
  Inserts a model given a map with resource attributes.

  Options are sent directly to the selected adapter.
  See Dayron.Adapter.insert/3 for avaliable options.

  ## Possible Exceptions
    * `Dayron.ServerError` - if server responds with a 500 internal error.
    * `Dayron.ClientError` - for any error detected in client side, such as
    timeout or connection errors.

  ## Example

      case RestRepo.insert User, %{name: "Dayse"} do
        {:ok, model}    -> # Inserted with success
        {:error, error} -> # Something went wrong
      end

  """
  def insert(_module, _data, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc """
  Similar to `insert/3` but raises a `Dayron.ValidationError` if server
  responds with a 422 unprocessable entity.
  """
  def insert!(_module, _data, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc """
  Updates a model given an id and a map with resource attributes.

  Options are sent directly to the selected adapter.
  See Dayron.Adapter.insert/3 for avaliable options.

  ## Possible Exceptions
    * `Dayron.ServerError` - if server responds with a 500 internal error.
    * `Dayron.ClientError` - for any error detected in client side, such as
    timeout or connection errors.

  ## Example

      case RestRepo.update User, "user-id", %{name: "Dayse"} do
        {:ok, model}    -> # Updated with success
        {:error, error} -> # Something went wrong
      end

  """
  def update(_module, _id, _data, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc """
  Similar to `insert/4` but raises:
    * `Dayron.NoResultsError` - if server responds with 404 resource not found.
    * `Dayron.ValidationError` - if server responds with 422 unprocessable
      entity.
  """
  def update!(_module, _id, _data, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc """
  Deletes a resource given a model and id.

  It returns `{:ok, model}` if the resource has been successfully
  deleted or `{:error, error}` if there was a validation
  or a known constraint error.

  Options are sent directly to the selected adapter.
  See `Dayron.Adapter.delete/3` for avaliable options.

  ## Possible Exceptions
    * `Dayron.ServerError` - if server responds with a 500 internal error.
    * `Dayron.ClientError` - for any error detected in client side, such as
    timeout or connection errors.
  """
  def delete(_module, _id, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc """
  Similar to `delete/3` but raises:
    * `Dayron.NoResultsError` - if server responds with 404 resource not found.
    * `Dayron.ValidationError` - if server responds with 422 unprocessable
      entity.
  """
  def delete!(_module, _id, _opts \\ []) do
    raise @cannot_call_directly_error
  end

  @doc false
  def get(adapter, model, request_data, logger, config) do
    {_request, response} =
      config
        |> Config.init_request_data(:get, model, request_data)
        |> execute!(adapter, logger)

    case response do
      %Response{status_code: 200, body: body} ->
        Model.from_json(model, body)
      %Response{status_code: code} when code >= 300 and code < 500 ->
        nil
    end
  end

  @doc false
  def get!(adapter, model, request_data, logger, config) do
    {request, response} =
      config
        |> Config.init_request_data(:get, model, request_data)
        |> execute!(adapter, logger)

    case response do
      %Response{status_code: 200, body: body} ->
        Model.from_json(model, body)
      %Response{status_code: code} when code >= 300 and code < 500 ->
        raise Dayron.NoResultsError, request: request
    end
  end

  @doc false
  def all(adapter, model, request_data, logger, config) do
    {_request, response} =
      config
        |> Config.init_request_data(:get, model, request_data)
        |> execute!(adapter, logger)

    case response do
      %Response{status_code: 200, body: body} ->
        Model.from_json_list(model, body)
    end
  end

  @doc false
  def insert(adapter, model, request_data, logger, config) do
    {request, response} =
      config
        |> Config.init_request_data(:post, model, request_data)
        |> execute!(adapter, logger)

    case response do
      %Response{status_code: 201, body: body} ->
        {:ok, Model.from_json(model, body)}
      %Response{status_code: 422, body: body} ->
        {:error, %{method: request.method, url: request.url, response: body}}
    end
  end

  @doc false
  def insert!(adapter, model, request_data, logger, config) do
    case insert(adapter, model, request_data, logger, config) do
      {:ok, model} -> {:ok, model}
      {:error, error} -> raise Dayron.ValidationError, Map.to_list(error)
    end
  end

  @doc false
  def update(adapter, model, request_data, logger, config) do
    {request, response} =
      config
        |> Config.init_request_data(:patch, model, request_data)
        |> execute!(adapter, logger)

    case response do
      %Response{status_code: 200, body: body} ->
        {:ok, Model.from_json(model, body)}
      %Response{status_code: code} when code >= 400 and code < 500 ->
        {:error, %{request: request, response: response, status_code: code}}
    end
  end

  @doc false
  def update!(adapter, model, request_data, logger, config) do
    case update(adapter, model, request_data, logger, config) do
      {:ok, model} -> {:ok, model}
      {:error, %{status_code: 404} = error} ->
        raise Dayron.NoResultsError, Map.to_list(error)
      {:error, %{status_code: 422} = error} ->
        raise Dayron.ValidationError, Map.to_list(error)
    end
  end

  @doc false
  def delete(adapter, model, request_data, logger, config) do
    {request, response} =
      config
        |> Config.init_request_data(:delete, model, request_data)
        |> execute!(adapter, logger)

    case response do
      %Response{status_code: 200, body: body} ->
        {:ok, Model.from_json(model, body)}
      %Response{status_code: 204} -> {:ok, nil}
      %Response{status_code: code, body: body}
      when code >= 400 and code < 500 ->
        {:error, %{method: request.method, code: code, url: request.url,
                   response: body}}
    end
  end

  @doc false
  def delete!(adapter, model, request_data, logger, config) do
    case delete(adapter, model, request_data, logger, config) do
      {:ok, model} -> {:ok, model}
      {:error, %{code: 404} = error} ->
        raise Dayron.NoResultsError, Map.to_list(error)
      {:error, %{code: 422} = error} ->
        raise Dayron.ValidationError, Map.to_list(error)
    end
  end

  defp execute!(%Request{} = request, adapter, logger) do
    request
    |> Request.send(adapter)
    |> log_request(logger)
    |> handle_errors
  end

  defp handle_errors({request, response}) do
    case response do
      %Response{status_code: 500} ->
        raise Dayron.ServerError, request: request, response: response
      %Dayron.ClientError{reason: reason} -> :ok
        raise Dayron.ClientError, request: request, reason: reason
      _ -> {request, response}
    end
  end

  defp log_request(data, nil), do: data
  defp log_request({request, response}, logger) do
    :ok = logger.log(request, response)    
    {request, response}
  end
end
