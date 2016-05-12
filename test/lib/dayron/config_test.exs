defmodule Dayron.ConfigTest do
  use ExUnit.Case, async: true
  alias Dayron.Config

  defmodule FakeAdapter do
    
  end

  setup do
    Application.put_env(:dayron_test, Dayron.Repo, 
      url: "http://api.example.com",
      headers: [access_token: "token"]
    )
  end

  test "parses a valid config" do    
    {otp_app, adapter, config} = Config.parse(Dayron.Repo, otp_app: :dayron_test, adapter: Dayron.ConfigTest.FakeAdapter)
    assert otp_app == :dayron_test
    assert adapter == Dayron.ConfigTest.FakeAdapter
    assert config[:url] == "http://api.example.com"
    assert config[:headers] == [access_token: "token"]
  end

  test "raises an exception if url is missing in config" do
    Application.put_env(:dayron_test, Dayron.Repo, [])
    msg = "missing :url configuration in config :dayron_test, Dayron.Repo"
    assert_raise ArgumentError, msg, fn ->
      Config.parse(Dayron.Repo, otp_app: :dayron_test)
    end
  end

  test "raises an exception if url is invalid in config" do
    Application.put_env(:dayron_test, Dayron.Repo, [url: "invalid-url"])
    msg = ~r/invalid URL for :url configuration in config :dayron_test/
    assert_raise ArgumentError, msg, fn ->
      Config.parse(Dayron.Repo, otp_app: :dayron_test)
    end
  end

  test "returns a default adapter if nothing is config" do
    {otp_app, adapter, _} = Config.parse(Dayron.Repo, otp_app: :dayron_test)
    assert otp_app == :dayron_test
    assert adapter == Dayron.HTTPoisonAdapter
  end

  test "returns default value for get_logger?" do
    {_, _, config} = Config.parse(Dayron.Repo, otp_app: :dayron_test)
    assert Config.get_logger(config) == Dayron.BasicLogger
  end

  defmodule MyLogger do
    
  end

  test "returns application logger config" do
    Application.put_env(:dayron_test, Dayron.Repo, [url: "http://api.example.com", logger: MyLogger])
    {_, _, config} = Config.parse(Dayron.Repo, otp_app: :dayron_test)
    assert Config.get_logger(config) == MyLogger
  end

  defmodule MyModel do
    use Dayron.Model, resource: "resources"

    defstruct name: "", age: 0
  end

  test "returns a valid request url" do
    {_, _, config} = Config.parse(Dayron.Repo, otp_app: :dayron_test)
    url = Config.get_request_url(config, MyModel, id: 1)
    assert url == "http://api.example.com/resources/1"
  end

  test "returns config headers" do
    {_, _, config} = Config.parse(Dayron.Repo, otp_app: :dayron_test)
    headers = Config.get_headers(config)
    assert headers[:access_token] == "token"
  end

  test "accepts url from a system env" do
    System.put_env("API_URL", "http://stage-api.example.com")
    Application.put_env(:dayron_test, Dayron.Repo, url: {:system, "API_URL"})
    {_, _, config} = Config.parse(Dayron.Repo, otp_app: :dayron_test)
    url = Config.get_request_url(config, MyModel, id: 1)
    assert url == "http://stage-api.example.com/resources/1"
  end
end
