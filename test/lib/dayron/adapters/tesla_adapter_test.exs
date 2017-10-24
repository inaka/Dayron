defmodule Dayron.TeslaAdapterTest do
  use ExUnit.Case, async: true
  alias Dayron.TeslaAdapter

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass, api_url: "http://localhost:#{bypass.port}"}
  end

  test "returns a decoded body for a valid get request", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/id" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, ~s<{"name": "Full Name", "address":{"street": "Elm Street", "zipcode": "88888"}}>)
    end
    response = TeslaAdapter.get("#{api_url}/resources/id")
    assert {:ok, %Dayron.Response{status_code: 200, body: body}} = response
    assert body[:name] == "Full Name"
    assert body[:address] == %{street: "Elm Street", zipcode: "88888"}
  end

  test "handles response body 'ok'", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/id" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, "ok")
    end
    response = TeslaAdapter.get("#{api_url}/resources/id")
    assert {:ok, %Dayron.Response{status_code: 200, body: body}} = response
    assert body == %{}
  end

  test "handles invalid json body", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/id" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, "{invalid_json=1}")
    end
    response = TeslaAdapter.get("#{api_url}/resources/id")
    assert {:ok, %Dayron.Response{status_code: 200, body: body}} = response
    assert body == "{invalid_json=1}"
  end

  test "returns a decoded body for a response list", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, ~s<[{"name": "First Resource"}, {"name": "Second Resource"}]>)
    end
    response = TeslaAdapter.get("#{api_url}/resources")
    assert {:ok, %Dayron.Response{status_code: 200, body: body}} = response
    [first, second | _t] = body
    assert first[:name] == "First Resource"
    assert second[:name] == "Second Resource"
  end

  test "accepts query parameters and headers", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources" == conn.request_path
      assert "q=qu+ery&page=2" == conn.query_string
      assert [{"accept", "application/json"} | _] = conn.req_headers
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, "")
    end
    response = TeslaAdapter.get("#{api_url}/resources", [{"accept", "application/json"}], [params: [{:q, "qu ery"}, {:page, 2}]])
    assert {:ok, %Dayron.Response{status_code: 200, body: _}} = response
  end

  test "accepts custom headers", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/id" == conn.request_path
      assert {"accesstoken", "token"} in conn.req_headers
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, "")
    end
    response = TeslaAdapter.get("#{api_url}/resources/id", [accesstoken: "token"])
    assert {:ok, %Dayron.Response{status_code: 200, body: _}} = response
  end

  test "returns a 404 response", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/invalid" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 404, "")
    end
    response = TeslaAdapter.get("#{api_url}/resources/invalid")
    assert {:ok, %Dayron.Response{status_code: 404, body: _}} = response
  end

  test "returns a 500 error response", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/server-error" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 500, "")
    end
    response = TeslaAdapter.get("#{api_url}/resources/server-error")
    assert {:ok, %Dayron.Response{status_code: 500, body: _}} = response
  end

  test "returns an error for invalid server" do
    response = TeslaAdapter.get("http://localhost:0001/resources/error")
    assert {:error, %Dayron.ClientError{reason: :econnrefused}} = response
  end

  test "returns a decoded body for a valid post request", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources" == conn.request_path
      assert [{"accept", "application/json"} | _] = conn.req_headers
      assert "POST" == conn.method
      Plug.Conn.resp(conn, 201, ~s<{"name": "Full Name", "age": 30}>)
    end
    response = TeslaAdapter.post("#{api_url}/resources", %{name: "Full Name", age: 30}, [{"accept", "application/json"}])
    assert {:ok, %Dayron.Response{status_code: 201, body: body}} = response
    assert body[:name] == "Full Name"
    assert body[:age] == 30
  end

  test "returns a decoded body for a valid patch request", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/id" == conn.request_path
      assert [{"accept", "application/json"} | _] = conn.req_headers
      assert "PATCH" == conn.method
      Plug.Conn.resp(conn, 200, ~s<{"name": "Full Name", "age": 30}>)
    end
    response = TeslaAdapter.patch("#{api_url}/resources/id", %{name: "Full Name", age: 30}, [{"accept", "application/json"}])
    assert {:ok, %Dayron.Response{status_code: 200, body: body}} = response
    assert body[:name] == "Full Name"
    assert body[:age] == 30
  end

  test "returns an empty body for a valid delete request", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/id" == conn.request_path
      assert [{"content-type", "application/json"}|_] = conn.req_headers
      assert "DELETE" == conn.method
      Plug.Conn.resp(conn, 204, "")
    end
    response = TeslaAdapter.delete("#{api_url}/resources/id", [{"content-type", "application/json"}])
    assert {:ok, %Dayron.Response{status_code: 204, body: nil}} = response
  end

  test "passing a custom hackney option works", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      case conn.request_path do
        "/old" ->
          conn
          |> Plug.Conn.put_resp_header("location", "/new")
          |> Plug.Conn.resp(301, "You are being redirected.")
          |> Plug.Conn.halt
        "/new" ->
          Plug.Conn.resp(conn, 200, "bar")
      end
    end
    response = TeslaAdapter.post("#{api_url}/old", "foo", [], [
      {:follow_redirect, true},
      {:hackney, [{:force_redirect, true}]}
    ])
    assert {:ok, %Dayron.Response{status_code: 200, body: body}} = response
    assert body == "bar"
  end
end
