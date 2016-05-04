defmodule Dayron.Adapter do
  @moduledoc ~S"""
  Behaviour for creating Dayron Adapters

  Adapters are wrappers around client libraries, responsible to send HTTP
  requests and parse the response status and body.

  ## Example

      defmodule Dayron.CustomAdapter do
        @behaviour Dayron.Adapter

        def get(url, headers, opts) do
          make_a_get_request(url, headers, opts)
        end
      end
  """
  require HTTPoison
  alias HTTPoison.Response
  alias HTTPoison.Error

  @type headers :: [{binary, binary}] | %{binary => binary}
  @type response :: {:ok, Response.t} | {:error, Error.t}

  @doc """
  Issues a GET request to the given url. The headers param is an enumerable
  consisting of two-item tuples that will be sent as request headers.

      Returns `{:ok, response}` if the request is successful,
              `{:error, reason}` otherwise.

  ## Options:
    * `:timeout` - timeout to establish a connection, in milliseconds.
    * `:recv_timeout` - timeout used when receiving a connection.
    * `:stream_to` - a PID to stream the response to
    * `:proxy` - a proxy to be used for the request;
      it can be a regular url or a `{Host, Proxy}` tuple
    * `:proxy_auth` - proxy authentication `{User, Password}` tuple
    * `:ssl` - SSL options supported by the `ssl` erlang module
    * `:follow_redirect` - a boolean that causes redirects to be followed
    * `:max_redirect` - the maximum number of redirects to follow
    * `:params` - an enumerable consisting of two-item tuples that will be
      appended to the url as query string parameters

  Timeouts can be an integer or `:infinity`.
  Check the adapter implementations for default values.
  """
  @callback get(binary, headers, Keyword.t) :: response
end
