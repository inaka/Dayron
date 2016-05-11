defmodule Dayron.Logger do
  @moduledoc """
  Helper module wrapping Logger calls to register request/response events
  """
  require HTTPoison
  require Logger

  @doc """
  Logs a debug or error message based on response code.
  """
  def log(method, url, response, req_details \\ []) do
    do_log(method, url, response, req_details)
    response
  end

  @doc """
  Logs a debug message for response codes between 200-399.
  """
  def do_log(method, url, %HTTPoison.Response{status_code: code}, req_details) when code < 400 do
    Logger.debug [method, ?\s, url, ?\s, "-> #{code}"]
    log_request_details :debug, req_details
  end

  @doc """
  Logs an error message for error response codes, or greater than 400.
  """
  def do_log(method, url, %HTTPoison.Response{status_code: code}, req_details) do
    Logger.error [method, ?\s, url, ?\s, "-> #{code}"]
    log_request_details :debug, req_details
  end

  @doc """
  Logs an error message for response error/exception.
  """
  def do_log(method, url, %HTTPoison.Error{reason: reason}, req_details) do
    Logger.error [method, ?\s, url, ?\s, "-> #{reason}"]
    log_request_details :error, req_details
  end

  defp log_request_details(level, req_details) do
    if Enum.any?(req_details) do
      Logger.log(level, "Request: \n #{inspect req_details, pretty: true}")
    end
  end

end
