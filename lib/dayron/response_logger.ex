defmodule Dayron.ResponseLogger do
  @moduledoc """
  Helper module wrapping Logger calls to register request/response events
  """
  require HTTPoison
  require Logger

  def log(method, url, _headers, _opts, %HTTPoison.Response{status_code: code}) when code < 400 do
    Logger.debug [method, ?\s, url, ?\s, "-> #{code}"]
  end

  def log(method, url, _headers, _opts, %HTTPoison.Response{status_code: code}) do
    Logger.error [method, ?\s, url, ?\s, "-> #{code}"]
  end

  def log(method, url, _headers, _opts, %HTTPoison.Error{reason: reason}) do
    Logger.error [method, ?\s, url, ?\s, "-> #{reason}"]
  end

end
