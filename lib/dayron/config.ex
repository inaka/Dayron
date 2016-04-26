defmodule Dayron.Config do
  @moduledoc """
  Helpers to handle application configuration values.
  """

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
end
