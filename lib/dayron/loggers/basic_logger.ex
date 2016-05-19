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
  def log(request, %Response{status_code: code} = response) when code < 500 do
    do_log(:debug, request, response)
  end

  @doc """
  Logs an error message for error response codes, or greater than 400.
  """
  def log(request, %Response{} = response), do:
    do_log(:error, request, response)

  @doc """
  Logs an error message for response error/exception.
  """
  def log(request, %ClientError{} = response) do
    response = %{response | request: request}
    Logger.error ClientError.message(response)
  end

  defp do_log(level, request, response) do
    Logger.log level, inspect(request, pretty: true)
    Logger.log level, inspect(response, pretty: true)
  end
end
