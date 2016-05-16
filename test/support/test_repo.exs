defmodule Dayron.TestAdapter do
  @behaviour Dayron.Adapter
  alias Dayron.Response
  alias Dayron.ClientError

  def get("http://localhost/resources", [], [body: body]) do
    {:ok, %Response{status_code: 200, body: body}}
  end

  def get("http://localhost/resources", _, [params: [{:q, "qu ery"}, {:page, 2}]]) do
    {:ok, %Response{status_code: 200, body: []}}
  end

  def get("http://localhost/resources", [], [error: "server-error"]) do
    {:ok, %Response{status_code: 500, body: "Internal Exception..."}}
  end

  def get("http://localhost/resources", [], [error: "connection-error"]) do
    {:error, %ClientError{id: nil, reason: :econnrefused}}
  end

  def get("http://localhost/resources", [], [error: "timeout-error"]) do
    {:error, %ClientError{id: nil, reason: :connect_timeout}}
  end

  def get("http://localhost/resources/id", [], [body: body]) do
    {:ok, %Response{status_code: 200, body: body}}
  end

  def get("http://localhost/resources/invalid-id", [], []) do
    {:ok, %Response{status_code: 404, body: ""}}
  end

  def get("http://localhost/resources/server-error", [], []) do
    {:ok, %Response{status_code: 500, body: "Internal Exception..."}}
  end

  def get("http://localhost/resources/connection-error", [], []) do
    {:error, %ClientError{id: nil, reason: :econnrefused}}
  end

  def get("http://localhost/resources/timeout-error", [], []) do
    {:error, %ClientError{id: nil, reason: :connect_timeout}}
  end

  def post("http://localhost/resources", %{error: "server-error"}, [], []) do
    {:ok, %Response{status_code: 500, body: "Internal Exception..."}}
  end

  def post("http://localhost/resources", %{error: "connection-error"}, [], []) do
    {:error, %ClientError{id: nil, reason: :econnrefused}}
  end

  def post("http://localhost/resources", %{name: nil}, [], []) do
    {:ok, %Response{status_code: 422, body: %{error: "name is required"}}}
  end

  def post("http://localhost/resources", model, [], []) do
    model = Map.put(model, :id, "new-model-id")
    {:ok, %Response{status_code: 201, body: model}}
  end

  def patch("http://localhost/resources/id", %{name: nil}, [], []) do
    {:ok, %Response{status_code: 422, body: %{error: "name is required"}}}
  end

  def patch("http://localhost/resources/id", %{error: "server-error"}, [], []) do
    {:ok, %Response{status_code: 500, body: "Internal Exception..."}}
  end

  def patch("http://localhost/resources/id", %{error: "connection-error"}, [], []) do
    {:error, %ClientError{id: nil, reason: :econnrefused}}
  end

  def patch("http://localhost/resources/invalid-id", _, [], []) do
    {:ok, %Response{status_code: 404, body: ""}}
  end

  def patch("http://localhost/resources/id", model, [], []) do
    model = Map.put(model, :id, "updated-model-id")
    {:ok, %Response{status_code: 200, body: model}}
  end

  def delete("http://localhost/resources/id", [], []) do
    {:ok, %Response{status_code: 200, body: %{id: "deleted-model-id"}}}
  end

  def delete("http://localhost/resources/invalid-id", [], []) do
    {:ok, %Response{status_code: 404, body: ""}}
  end

  def delete("http://localhost/resources/validation-error-id", [], []) do
    {:ok, %Response{status_code: 422, body: ""}}
  end

  def delete("http://localhost/resources/server-error", [], []) do
    {:ok, %Response{status_code: 500, body: "Internal Exception..."}}
  end

  def delete("http://localhost/resources/connection-error", [], []) do
    {:error, %ClientError{id: nil, reason: :econnrefused}}
  end

  def delete("http://localhost/resources/timeout-error", [], []) do
    {:error, %ClientError{id: nil, reason: :connect_timeout}}
  end
end

defmodule Dayron.TestLogger do
  @behaviour Dayron.Logger

  def log(_request, _response), do: :ok
end


Application.put_env(:dayron, Dayron.TestRepo, [url: "http://localhost", logger: Dayron.TestLogger])

defmodule Dayron.TestRepo do
  use Dayron.Repo, otp_app: :dayron, adapter: Dayron.TestAdapter
end
