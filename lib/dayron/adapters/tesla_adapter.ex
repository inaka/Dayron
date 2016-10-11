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

    adapter Tesla.Adapter.Hackney
  end

  @doc """
  Implementation for `Dayron.Adapter.get/3`.
  """
  def get(url, headers \\ [], opts \\ []) do
    Client.get(url, headers: headers) |> translate_response
  end

  @doc """
  Implementation for `Dayron.Adapter.post/4`.
  """
  def post(url, body, headers \\ [], opts \\ []) do
    Client.post(url, body, headers: headers) |> translate_response
  end

  @doc """
  Implementation for `Dayron.Adapter.patch/4`.
  """
  def patch(url, body, headers \\ [], opts \\ []) do
    Client.patch(url, body, headers: headers) |> translate_response
  end

  @doc """
  Implementation for `Dayron.Adapter.delete/3`.
  """
  def delete(url, headers \\ [], opts \\ []) do
    Client.delete(url, headers: headers) |> translate_response
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

  defp translate_response_body(body) do
    try do
      body |> Poison.decode!(keys: :atoms)
    rescue
      Poison.SyntaxError -> body
    end
  end

end
