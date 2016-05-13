defmodule Dayron.Request do
  @moduledoc """
  Defines a struct to store data necessary to send a request using an adapter.
  Also provides helper functions to map request data to adapter method calls.
  """
  defstruct method: :get, url: "", body: %{}, headers: [], options: []
  @type t :: %__MODULE__{method: atom, url: binary, body: map, headers: list,
                         options: list}

  @doc """
  Given a request struct and an adapter, calls the correct adapter function
  passing the correct parameters. Return a tuple with {request, response}.
  """
  def send(request, adapter) do
    opts = request.options
    {_, response} = case request.method do
      :get -> adapter.get(request.url, request.headers, opts)
      :post -> adapter.post(request.url, request.body, request.headers, opts)
      :patch -> adapter.patch(request.url, request.body, request.headers, opts)
      :delete -> adapter.delete(request.url, request.headers, opts)
    end

    {request, response}
  end
end
