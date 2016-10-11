defmodule Dayron.TeslaAdapter do
  @moduledoc """
  Makes http requests using Tesla library.
  Use this adapter to make http requests to an external Rest API.

  ## Example config
      config :my_app, MyApp.Repo,
        adapter: Dayron.TeslaAdapter,
        url: "https://api.example.com"
  """
  @behaviour Dayron.Adapter

  defmodule Client do
    @moduledoc """
    A Tesla Client implementation, sending json requests, parsing
    json responses to Maps or a List of Maps. Maps keys are also converted to
    atoms by default.
    """
    use Tesla

    # TODO: If the Tesla JSON decoding was a bit more flexible, properly
    # returning errors along with raw output and perhaps allowing a force
    # flag to ignore content-type header contents, we could use that instead
    # of our own custom decoding. Perhaps a pull request would do it..
    plug Tesla.Middleware.EncodeJson, engine: Poison
    plug Dayron.TeslaAdapter.Translator

    adapter Tesla.Adapter.Hackney
  end

  defmodule Translator do
    @moduledoc """
    A Tesla Middleware implementation, translating responses to the format
    expected by Dayron.
    """
    def call(env, next, opts \\ []) do
      env
      |> Tesla.run(next)
      |> translate_response()
    end

    defp translate_response(%Tesla.Env{} = response) do
      {:ok, %Dayron.Response{
          status_code: response.status,
          body: translate_response_body(response.body),
          headers: response.headers |> Map.to_list
        }
      }
    end
    defp translate_response({:error, response}) do
      data = response |> Map.from_struct
      {:error, struct(Dayron.ClientError, data)}
    end

    defp translate_response_body(""), do: nil
    defp translate_response_body("ok"), do: %{}
    defp translate_response_body(body) do
      try do
        body |> Poison.decode!(keys: :atoms)
      rescue
        Poison.SyntaxError -> body
      end
    end
  end

  @doc """
  Implementation for `Dayron.Adapter.get/3`.
  """
  def get(url, headers \\ [], opts \\ []) do
    query = Keyword.get(opts, :params, [])
    # TODO: Implement try..catch for remaining functions?
    try do
      Client.get(url, headers: Enum.into(headers, %{}), query: query)
    rescue
      e in Tesla.Error -> translate_error(e)
    end
  end

  @doc """
  Implementation for `Dayron.Adapter.post/4`.
  """
  def post(url, body, headers \\ [], opts \\ []) do
    Client.post(url, body, headers: Enum.into(headers, %{}))
  end

  @doc """
  Implementation for `Dayron.Adapter.patch/4`.
  """
  def patch(url, body, headers \\ [], opts \\ []) do
    Client.patch(url, body, headers: Enum.into(headers, %{}))
  end

  @doc """
  Implementation for `Dayron.Adapter.delete/3`.
  """
  def delete(url, headers \\ [], opts \\ []) do
    Client.delete(url, headers: Enum.into(headers, %{}))
  end

  defp translate_error(%Tesla.Error{reason: reason}) do
    {:error, %Dayron.ClientError{reason: reason}}
  end
end
