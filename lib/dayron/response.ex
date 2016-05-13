defmodule Dayron.Response do
  @moduledoc """
  Defines a struct to store the response data returned by an api request.
  """
  defstruct status_code: nil, body: nil, headers: []
  @type t :: %__MODULE__{status_code: integer, body: binary, headers: list}
end
