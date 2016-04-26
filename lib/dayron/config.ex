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
    url = opts[:url] || config[:url]

    unless url do
      raise ArgumentError, "missing :url configuration in " <>
                           "config #{inspect otp_app}, #{inspect repo}"
    end

    {otp_app, config}
  end

  def get_request_url(config, model, opts) do
    config[:url] <> Model.url_for(model, opts)
  end

  def get_headers(config) do
    Keyword.get(config, :headers, [])
  end
end
