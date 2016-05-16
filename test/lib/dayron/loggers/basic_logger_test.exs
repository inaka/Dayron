defmodule Dayron.BasicLoggerTest do
  use ExUnit.Case, async: true
  alias Dayron.BasicLogger
  alias Dayron.Request
  alias Dayron.Response
  alias Dayron.ClientError
  import ExUnit.CaptureIO
  
  defp capture_log(fun) do
    data = capture_io(:user, fn ->
      Process.put(:capture_log, fun.())
      Logger.flush()
    end)
    {Process.get(:capture_log), data}
  end

  setup do
    body = %{name: "Full Name", age: 30}
    options = [params: [{:q, "qu ery"}, {:page, 2}]]
    request = %Request{method: :get, url: "http://localhost/resources", body: body, headers: [access_token: "token"], options: options}
    {:ok, request: request}
  end

  test "logs a Response with success", %{request: request} do
    response = %Response{status_code: 200, elapsed_time: 28000}
    {:ok, output} = capture_log fn ->
      :ok = BasicLogger.log(request, response)
    end
    assert output =~ ~r/\[debug\] GET http\:\/\/localhost\/resources/ 
    assert output =~ ~r/\[debug\] Response: 200 in 28ms/
  end

  test "logs Response with error", %{request: request} do
    response = %Response{status_code: 500, elapsed_time: 5, body: "Internal Server Error"}
    {:ok, output} = capture_log fn ->
      :ok = BasicLogger.log(request, response)
    end
    assert output =~ ~r/\[error\] GET http\:\/\/localhost\/resources/ 
    assert output =~ ~r/\[error\] Response: 500 in 5µs/
  end

  test "logs ClientError exceptions", %{request: request} do
    response = %ClientError{reason: :timeout}
    {:ok, output} = capture_log fn ->
      :ok = BasicLogger.log(request, response)
    end

    assert output =~ ~r/\[error\] unexpected client error in request\:\n\nGET/ 
    assert output =~ ~r/Reason\: \:timeout/
  end
end
