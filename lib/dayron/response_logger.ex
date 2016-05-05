defmodule Dayron.ResponseLogger do
  @moduledoc """
  Helper module wrapping Logger calls to register request/response events
  """
  require HTTPoison
  require Logger

  @doc """
  Logs a debug message for response codes between 200-399.
  """
  def log(method, url, _headers, _opts, %HTTPoison.Response{status_code: code}) when code < 400 do
    Logger.debug [method, ?\s, url, ?\s, "-> #{code}"]
  end

  @doc """
  Logs an error message for error response codes, or greater than 400.
  """
  def log(method, url, _headers, _opts, %HTTPoison.Response{status_code: code}) do
    Logger.error [method, ?\s, url, ?\s, "-> #{code}"]
  end

  @doc """
  Logs an error message for response error/exception.
  """
  def log(method, url, _headers, _opts, %HTTPoison.Error{reason: reason}) do
    Logger.error [method, ?\s, url, ?\s, "-> #{reason}"]
  end

end
