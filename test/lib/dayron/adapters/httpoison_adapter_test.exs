defmodule Dayron.HTTPoisonAdapterTest do
  use ExUnit.Case, async: true
  alias Dayron.HTTPoisonAdapter

  setup do
    bypass = Bypass.open
    {:ok, bypass: bypass, api_url: "http://localhost:#{bypass.port}"}
  end

  test "returns a decoded body for a valid get request", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/id" == conn.request_path
      assert [{"content-type", "application/json"} | _] = conn.req_headers
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, ~s<{"name": "Full Name", "address":{"street": "Elm Street", "zipcode": "88888"}}>)
    end
    response = HTTPoisonAdapter.get("#{api_url}/resources/id")
    assert {:ok, %HTTPoison.Response{status_code: 200, body: body}} = response
    assert body[:name] == "Full Name"
    assert body[:address] == %{street: "Elm Street", zipcode: "88888"}
  end

  test "returns a decoded body for a response list", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources" == conn.request_path
      assert [{"content-type", "application/json"} | _] = conn.req_headers
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, ~s<[{"name": "First Resource"}, {"name": "Second Resource"}]>)
    end
    response = HTTPoisonAdapter.get("#{api_url}/resources")
    assert {:ok, %HTTPoison.Response{status_code: 200, body: body}} = response
    [first, second | _t] = body
    assert first[:name] == "First Resource"
    assert second[:name] == "Second Resource"
  end

  test "accepts custom headers", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/id" == conn.request_path
      assert [{"content-type", "application/json"} | _] = conn.req_headers
      assert [_a, _b, {"accesstoken", "token"} | _] = conn.req_headers
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 200, "")
    end
    response = HTTPoisonAdapter.get("#{api_url}/resources/id", [accesstoken: "token"])
    assert {:ok, %HTTPoison.Response{status_code: 200, body: _}} = response
  end

  test "returns a 404 response", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/invalid" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 404, "")
    end
    response = HTTPoisonAdapter.get("#{api_url}/resources/invalid")
    assert {:ok, %HTTPoison.Response{status_code: 404, body: _}} = response
  end

  test "returns a 500 error response", %{bypass: bypass, api_url: api_url} do
    Bypass.expect bypass, fn conn ->
      assert "/resources/server-error" == conn.request_path
      assert "GET" == conn.method
      Plug.Conn.resp(conn, 500, "")
    end
    response = HTTPoisonAdapter.get("#{api_url}/resources/server-error")
    assert {:ok, %HTTPoison.Response{status_code: 500, body: _}} = response
  end

  test "returns an error for invalid server" do
    response = HTTPoisonAdapter.get("http://localhost:0001/resources/error")
    assert {:error, %HTTPoison.Error{reason: :econnrefused}} = response
  end
end
