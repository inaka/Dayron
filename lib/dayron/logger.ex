defmodule Dayron.Logger do
  @moduledoc ~S"""
  Behaviour for creating Dayron Loggers

  Loggers are responsible to print request and response data to an output.

  ## Example

      defmodule Dayron.CustomLogger do
        @behaviour Dayron.Logger
        
        require Logger

        def log(request, response) do
          Logger.debug(inspect(request))
          Logger.debug(inspect(response))
        end
      end
  """
  alias Dayron.Request
  alias Dayron.Response
  alias Dayron.ClientError

  @doc """
  Logs an message based on request and response data.
  """
  @callback log(Request.t, Response.t | ClientError.t) :: atom
end
