defmodule Dayron.HTTPoisonAdapter do
  @moduledoc """
  Makes http requests using HTTPoison library.
  Use this adapter to make http requests to an external Rest API.

  ## Example config
      config :my_app, MyApp.Repo,
        adapter: Dayron.HTTPoisonAdapter,
        url: "https://api.example.com"
  """
  @behaviour Dayron.Adapter

  defmodule Client do
    @moduledoc """
    A HTTPoison.Base Client implementation, sending json requests, parsing
    json responses to Maps or a List of Maps. Maps keys are also converted to
    atoms by default.
    """
    require Crutches
    require Poison
    use HTTPoison.Base

    def process_request_body(body), do: Poison.encode!(body)

    def process_response_body(""), do: nil
    def process_response_body("ok"), do: %{}

    def process_response_body(body) do
      body |> Poison.decode! |> process_decoded_body
    end

    defp process_decoded_body(body) when is_list(body) do
      body |> Enum.map(&process_decoded_body(&1))
    end

    defp process_decoded_body(body) do
      body
      |> Enum.into(%{})
      |> Crutches.Map.dkeys_update(fn (key) -> String.to_atom(key) end)
    end

    @doc """
    Merges headers received as argument with default headers
    """
    def process_request_headers(headers) when is_list(headers) do
      Enum.into(headers, [
        {"Content-Type", "application/json"},
        {"Accept", "application/json"},
      ])
    end
  end

  @doc """
  Implementation for `Dayron.Adapter.get/3`.
  """
  def get(url, headers \\ [], opts \\ []) do
    Client.start
    Client.get(url, headers, opts)
  end

  @doc """
  Implementation for `Dayron.Adapter.post/4`.
  """
  def post(url, body, headers \\ [], opts \\ []) do
    Client.start
    Client.post(url, body, headers, opts)
  end

  @doc """
  Implementation for `Dayron.Adapter.patch/4`.
  """
  def patch(url, body, headers \\ [], opts \\ []) do
    Client.start
    Client.patch(url, body, headers, opts)
  end
end
