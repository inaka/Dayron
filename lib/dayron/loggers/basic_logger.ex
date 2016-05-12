defmodule Dayron.BasicLogger do
  @moduledoc """
  Helper module wrapping Logger calls to register request/response events
  """
  require Logger
  alias Dayron.Response
  alias Dayron.ClientError

  @doc """
  Logs a debug message for response codes between 200-399.
  """
  def log(request, %Response{status_code: code}) when code < 400 do
    Logger.debug fn ->
      [inspect_method(request.method), ?\s, request.url, ?\s, "-> #{code}"]
    end
    log_request_body(:debug, request.body)
  end

  @doc """
  Logs an error message for error response codes, or greater than 400.
  """
  def log(request, %Response{status_code: code}) do
    Logger.error fn ->
      [inspect_method(request.method), ?\s, request.url, ?\s, "-> #{code}"]
    end
    log_request_body(:error, request.body)
  end

  @doc """
  Logs an error message for response error/exception.
  """
  def log(request, %ClientError{reason: reason}) do
    Logger.error fn ->
      [inspect_method(request.method), ?\s, request.url, ?\s, "-> #{reason}"]
    end
    log_request_body(:error, request.body)
  end

  defp inspect_method(method) do
    method |> Atom.to_string |> String.upcase
  end

  defp log_request_body(level, nil), do: :ok
  defp log_request_body(level, body) do
    if Enum.any?(body) do
      Logger.log level, fn ->
        ["Request body:", ?\s, inspect(body, pretty: true)]
      end
    end
  end

end
