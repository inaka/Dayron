defmodule Dayron.Adapter do
  @moduledoc ~S"""
  Behaviour for creating Dayron adapters

  Adapters are wrappers around client libraries, responsible to send the HTTP requests and parse the response code and body.

  ## Example

      defmodule Dayron.CustomAdapter do
        @behaviour Dayron.Adapter

        def get(url, headers, opts) do
          make_a_get_request(url, headers, opts)
        end
      end
  """
  require HTTPoison

  @type http_response :: {atom, HTTPoison.Response.t}

  @callback get(String.t, Keyword.t, Keyword.t) :: http_response
end
