defmodule Dayron.Client do
  require Crutches
  use HTTPoison.Base

  def process_response_body(_body = ""), do: nil

  def process_response_body(body) do
    body
    |> Poison.decode!
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
