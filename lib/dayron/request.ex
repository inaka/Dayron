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

defimpl Inspect, for: Dayron.Request do
  @moduledoc """
  Implementing Inspect protocol for Dayron.Request
  It changes the output for pretty:true option

  ## Example:

      > inspect request, pretty: true
      GET http://api.example.com
      Options:
        Params: q="qu", page=2
        Timeout: 8000
      Body:
        Name: "Dayse"
      Headers:
        access_token: "token"
  """
  import Inspect.Algebra
  @tab_width 5

  def inspect(request, %Inspect.Opts{pretty: true}) do
    concat([
      title(request),
      "\n",
      nest(
        glue(
          "Options:",
          list_to_doc(request.options, 2)
        ), @tab_width
      ),
      "\n",
      nest(
        glue(
          "Body:",
          list_to_doc(request.body, 2)
        ), @tab_width
      ),
      "\n",
      nest(
        glue(
          "Headers:",
          list_to_doc(request.headers, 2)
        ), @tab_width
      )
    ])
  end
  def inspect(request, opts), do: Inspect.Any.inspect(request, opts)

  defp title(request) do
    glue method_to_string(request.method), request.url
  end

  defp method_to_string(nil), do: "NO_METHOD"
  defp method_to_string(method) when is_atom(method) do
    method |> Atom.to_string |> String.upcase
  end

  defp list_to_doc(nil, _level), do: "-"
  defp list_to_doc([], _level), do: "-"
  defp list_to_doc(%{}, _level), do: "-"
  defp list_to_doc(list, level) do
    Enum.map(list, fn
      {key, value} when is_list(value) ->
        nest(
          glue(
            concat(Atom.to_string(key) |> String.capitalize, ":"),
            list_to_doc(value, level + 1)
          ), @tab_width * level
        )
      {key, value} ->
        concat(Atom.to_string(key) <> "=", inspect(value))
      value -> inspect(value)
    end) |> fold_doc(&glue(&1,&2))
  end
end
