defmodule Dayron.TeslaAdapter do
  @moduledoc """
  Makes http requests using Tesla library.
  Use this adapter to make http requests to an external Rest API.

  ## Example config
      config :my_app, MyApp.Repo,
        adapter: Dayron.TeslaAdapter,
        url: "https://api.example.com"

  ## TODO

  - Handle options to the Tesla client, see `Dayron.Adapter`
  """
  @behaviour Dayron.Adapter

  defmodule Client do
    @moduledoc """
    A Tesla Client implementation, sending json requests, parsing
    json responses to Maps or a List of Maps. Maps keys are also converted to
    atoms by default.
    """
    use Tesla

    plug Tesla.Middleware.EncodeJson, engine: Poison
    plug Dayron.TeslaAdapter.Translator

    adapter Tesla.Adapter.Hackney
  end

  defmodule Translator do
    @moduledoc """
    A Tesla Middleware implementation, translating responses to the format
    expected by Dayron.

    We're also doing JSON decoding of responses here, as the built-in JSON
    middleware in Tesla will only decode content-type `application/json`, as
    well as raise an error on decoding issues instead of returning the raw
    input. Both of these differences break the existing implicit contract, as
    implemented by `Dayron.HTTPoisonAdapter`.
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

    defp translate_response_body(""), do: nil
    defp translate_response_body("ok"), do: %{}
    defp translate_response_body(body) do
      try do
        body |> Poison.decode!(keys: :atoms)
      rescue
        Poison.SyntaxError -> body
      end
    end

    def translate_error(%Tesla.Error{} = error) do
      data = error |> Map.from_struct
      {:error, struct(Dayron.ClientError, data)}
    end
  end

  @doc """
  Implementation for `Dayron.Adapter.get/3`.
  """
  def get(url, headers \\ [], opts \\ []) do
    query = Keyword.get(opts, :params, [])
    tesla_call(:get, [url, [headers: Enum.into(headers, %{}), query: query]])
  end

  @doc """
  Implementation for `Dayron.Adapter.post/4`.
  """
  def post(url, body, headers \\ [], opts \\ []) do
    tesla_call(:post, [url, body, [headers: Enum.into(headers, %{})]])
  end

  @doc """
  Implementation for `Dayron.Adapter.patch/4`.
  """
  def patch(url, body, headers \\ [], opts \\ []) do
    tesla_call(:patch, [url, body, [headers: Enum.into(headers, %{})]])
  end

  @doc """
  Implementation for `Dayron.Adapter.delete/3`.
  """
  def delete(url, headers \\ [], opts \\ []) do
    tesla_call(:delete, [url, [headers: Enum.into(headers, %{})]])
  end

  defp tesla_call(method, args) do
    try do
      apply(Client, method, args)
    rescue
      e in Tesla.Error -> Translator.translate_error(e)
    end
  end
end
