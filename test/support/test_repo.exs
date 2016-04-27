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
    {:ok, %HTTPoison.Response{status_code: 500, body: "Internal Exception..."}}
  end


  def get("http://localhost/resources/connection-error", [], []) do
    {:error, %HTTPoison.Error{id: nil, reason: :econnrefused}}
  end

  def get("http://localhost/resources/timeout-error", [], []) do
    {:error, %HTTPoison.Error{id: nil, reason: :connect_timeout}}
  end

  %HTTPoison.Error{reason: :connect_timeout}
end

Application.put_env(:dayron, Dayron.TestRepo, [url: "http://localhost", enable_log: false])

defmodule Dayron.TestRepo do
  use Dayron.Repo, otp_app: :dayron, adapter: Dayron.TestAdapter
end
