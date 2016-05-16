defmodule Dayron.ResponseTest do
  use ExUnit.Case, async: true
  alias Dayron.Response

  test "implements a custom inspect" do
    response = %Response{status_code: 200, body: %{}, elapsed_time: 340}
    output = Kernel.inspect(response)
    assert output =~ ~r/%Dayron\.Response\{.*status_code\: 200\}/
  end

  test "implements a custom inspect for pretty: true" do
    response = %Response{status_code: 200, body: %{}, elapsed_time: 340000}
    output = Kernel.inspect(response, pretty: true)
    assert output =~ ~r/Response\: 200 in 340ms/
  end
end
