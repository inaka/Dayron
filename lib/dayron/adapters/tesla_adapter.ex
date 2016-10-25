defmodule Dayron.TeslaAdapter do
  @moduledoc """
  Makes http requests using Tesla library.
  Use this adapter to make http requests to an external Rest API.

  ## Example config
      config :my_app, MyApp.Repo,
        adapter: Dayron.TeslaAdapter,
        url: "https://api.example.com"

  ## TODO

  - Handle streaming
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
    def call(env, next, _opts) do
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
    tesla_call(:get, [url, build_options(headers, opts)])
  end

  @doc """
  Implementation for `Dayron.Adapter.post/4`.
  """
  def post(url, body, headers \\ [], opts \\ []) do
    tesla_call(:post, [url, body, build_options(headers, opts)])
  end

  @doc """
  Implementation for `Dayron.Adapter.patch/4`.
  """
  def patch(url, body, headers \\ [], opts \\ []) do
    tesla_call(:patch, [url, body, build_options(headers, opts)])
  end

  @doc """
  Implementation for `Dayron.Adapter.delete/3`.
  """
  def delete(url, headers \\ [], opts \\ []) do
    tesla_call(:delete, [url, build_options(headers, opts)])
  end

  defp tesla_call(method, args) do
    try do
      apply(Client, method, args)
    rescue
      e in Tesla.Error -> Translator.translate_error(e)
    end
  end

  def build_options([], opts), do: build_options(opts)
  def build_options(headers, opts) do
    build_options([{:headers, Enum.into(headers, %{})} | opts])
  end

  defp build_options(opts) do
    Enum.reduce(opts, [{:opts, build_hackney_options(opts)}], fn
      {:headers, value}, options -> [{:headers, value} | options]
      {:params, value}, options -> [{:query, value} | options]
      _, options -> options
    end)
  end

  defp build_hackney_options(opts) do
    Enum.reduce(opts, [], fn
      {:hackney, extra_opts}, hn_opts    -> hn_opts ++ extra_opts
      {:timeout, value}, hn_opts         -> [{:connect_timeout, value} | hn_opts]
      {:recv_timeout, value}, hn_opts    -> [{:recv_timeout, value} | hn_opts]
      {:proxy, value}, hn_opts           -> [{:proxy, value} | hn_opts]
      {:proxy_auth, value}, hn_opts      -> [{:proxy_auth, value} | hn_opts]
      {:ssl, value}, hn_opts             -> [{:ssl_options, value} | hn_opts]
      {:follow_redirect, value}, hn_opts -> [{:follow_redirect, value} | hn_opts]
      {:max_redirect, value}, hn_opts    -> [{:max_redirect, value} | hn_opts]
      #{:stream_to, arg}, hn_opts ->
      #  [:async, {:stream_to, spawn(module, :transformer, [arg])} | hn_opts]
      _other, hn_opts -> hn_opts
    end)
  end
end
