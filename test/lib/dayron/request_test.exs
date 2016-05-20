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

  test "implements a custom inspect for pretty: true", %{request: request} do
    output = Kernel.inspect(request, pretty: true)
    assert output =~ ~r/GET http\:\/\/localhost\/resources/
    assert output =~ ~r/Body\: age=30\n     name=\"Full Name\"/
    assert output =~ ~r/Params\: q\=\"qu ery\"/
  end

  test "implements a custom inspect for raw body", %{request: request} do
    request = %{request | body: "raw text"}
    output = Kernel.inspect(request, pretty: true)
    assert output =~ ~r/GET http\:\/\/localhost\/resources/
    assert output =~ ~r/Body\:\n     \"raw text\"/
  end

  test "implements a custom inspect for body as list", %{request: request} do
    request = %{request | body: ["item 1", "item 2"]}
    output = Kernel.inspect(request, pretty: true)
    assert output =~ ~r/GET http\:\/\/localhost\/resources/
    assert output =~ ~r/Body\: \"item 1\"\n     \"item 2\"/
  end

  test "implements a custom inspect for pretty: true for no options" do
    request = %Request{method: :get, url: "http://api.example.com"}
    output = Kernel.inspect(request, pretty: true)
    assert output =~ ~r/GET http\:\/\/api\.example\.com/
    assert output =~ ~r/Body\: \-/
    assert output =~ ~r/Options\: \-/
  end
end
