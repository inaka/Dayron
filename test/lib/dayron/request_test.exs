defmodule Dayron.RequestTest do
  use ExUnit.Case, async: true
  alias Dayron.Request

  setup do
    body = %{name: "Full Name", age: 30}
    options = [params: [{:q, "qu ery"}, {:page, 2}]]
    request = %Request{method: :get, url: "http://localhost/resources", body: body, headers: [access_token: "token"], options: options}
    {:ok, request: request}
  end

  test "sends a request to adapter", %{request: request} do
    {_, response} = Request.send(request, Dayron.TestAdapter)
    assert response.status_code == 200
    assert response.elapsed_time > 0
  end

  test "implements a custom inspect", %{request: request} do
    output = Kernel.inspect(request)
    assert output =~ ~r/%Dayron\.Request\{.*\}/
  end

  test "inspect request when body is list", %{request: request} do
    request = %{request | body: ["value1", "value2"]}
    output = Kernel.inspect(request)
    assert output =~ ~r/\[\"value1\", \"value2\"\]/
  end

  test "implements a custom inspect for pretty: true", %{request: request} do
    output = Kernel.inspect(request, pretty: true)
    assert output =~ ~r/GET http\:\/\/localhost\/resources/
    assert output =~ ~r/Params\: q\=\"qu ery\"/
  end

  test "implements a custom inspect for pretty: true for no options" do
    request = %Request{method: :get, url: "http://api.example.com"}
    output = Kernel.inspect(request, pretty: true)
    assert output =~ ~r/GET http\:\/\/api\.example\.com/
    assert output =~ ~r/Options\: \-/
  end
end
