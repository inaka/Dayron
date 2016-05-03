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
    @moduledoc false
    require Crutches
    require Poison
    use HTTPoison.Base

    def process_response_body(_body = ""), do: nil

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

    # HEADERS
    defp process_request_headers(headers) when is_list(headers) do
      Enum.into(headers, [
        {"Content-Type", "application/json"}
      ])
    end
  end

  def get(url, headers \\ [], opts \\ []) do
    Client.start
    Client.get(url, headers, opts)
  end
end
