require HTTPoison

defmodule Dayron.TestAdapter do
  @behaviour Dayron.Adapter

  def get("http://localhost/resources/id", [], [body: body]) do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}}
  end

  def get("http://localhost/resources/invalid-id", [], []) do
    {:ok, %HTTPoison.Response{status_code: 404, body: ""}}
  end

  def get("http://localhost/resources/server-error", [], []) do
    {:error, %HTTPoison.Error{id: nil, reason: "Server Error"}}
  end
end

Application.put_env(:dayron, Dayron.TestRepo, [url: "http://localhost"])

defmodule Dayron.TestRepo do
  use Dayron.Repo, otp_app: :dayron, adapter: Dayron.TestAdapter
end
