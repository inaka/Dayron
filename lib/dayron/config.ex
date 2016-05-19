defmodule Dayron.Config do
  @moduledoc """
  Helpers to handle application configuration values.
  """
  alias Dayron.Model

  @doc """
  Parses the OTP configuration for compilation time.
  """
  def parse(repo, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config  = Application.get_env(otp_app, repo, [])
    adapter = opts[:adapter] || config[:adapter] || Dayron.HTTPoisonAdapter
    logger = opts[:logger] || config[:logger] || Dayron.BasicLogger

    {otp_app, adapter, logger}
  end

  @doc """
  Retrieves and normalizes the configuration for `repo` in `otp_app`.
  """
  def get(repo, otp_app) do
    config = Application.get_env(otp_app, repo)
    if config do
      url = parse_url!(config, repo, otp_app)
      Keyword.merge(config, url: url)
    else
      raise ArgumentError,
        "configuration for #{inspect repo} not specified in" <>
        " #{inspect otp_app} environment"
    end
  end

  @doc """
  Given a config map, model and options, returns the complete url for the api
  request.

  ## Example

      > Config.get_request_url(config, MyModel, [id: id])
      "http://api.example.com/mymodels/id"
  """
  def get_request_url(config, model, opts) do
    config[:url] <> Model.url_for(model, opts)
  end

  @doc """
  Returns a `%Dayron.Request` with provided data and application config
  """
  def init_request_data(config, method, model, opts \\ []) do
    %Dayron.Request{
      method: method,
      url: get_request_url(config, model, opts),
      body: opts[:body],
      headers: Keyword.get(config, :headers, []),
      options: opts[:options]
    }
  end

  @doc """
  Parses the application configuration :url key, accepting system env or a
  binary
  """
  def parse_url!(config, repo, otp_app) do
    case parse_url(config[:url]) do
      {:ok, url} -> url
      {:error, :missing_url} ->
        raise ArgumentError, "missing :url configuration in " <>
                             "config #{inspect otp_app}, #{inspect repo}"
      {:error, _} ->
        raise ArgumentError, "invalid URL for :url configuration in " <>
                             "config #{inspect otp_app}, #{inspect repo}"
    end
  end
  def parse_url({:system, env}) when is_binary(env) do
    parse_url(System.get_env(env) || "")
  end

  def parse_url(url) when is_binary(url) do
    info = url |> URI.decode() |> URI.parse()

    if is_nil(info.host), do: {:error, :invalid_url}, else: {:ok, url}
  end

  def parse_url(_), do: {:error, :missing_url}
end
