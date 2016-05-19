defmodule Dayron.ConfigTest do
  use ExUnit.Case, async: true
  alias Dayron.Config

  defmodule MyAdapter do
  end

  defmodule MyLogger do    
  end


  setup do
    Application.put_env(:dayron_test, Dayron.Repo, 
      url: "http://api.example.com",
      headers: [access_token: "token"]
    )
  end

  test "parses a valid config" do    
    {otp_app, adapter, logger} = Config.parse(Dayron.Repo, otp_app: :dayron_test, adapter: Dayron.ConfigTest.MyAdapter, logger: Dayron.ConfigTest.MyLogger)
    assert otp_app == :dayron_test
    assert adapter == Dayron.ConfigTest.MyAdapter
    assert logger == Dayron.ConfigTest.MyLogger
  end

  test "returns default values when there is no config" do
    {otp_app, adapter, logger} = Config.parse(Dayron.Repo, otp_app: :invalid_app)
    assert otp_app == :invalid_app
    assert adapter == Dayron.HTTPoisonAdapter
    assert logger == Dayron.BasicLogger
  end

  test "retrieves a valid url from config" do
    config = Config.get(Dayron.Repo, :dayron_test)
    assert config[:url] == "http://api.example.com"
    assert config[:headers] == [access_token: "token"]
  end

  test "raises an exception if no config is present" do
    msg = "configuration for Dayron.Repo not specified in :invalid_app environment"
    assert_raise ArgumentError, msg, fn ->
      Config.get(Dayron.Repo, :invalid_app)
    end
  end  

  test "raises an exception if url is missing in config" do
    Application.put_env(:dayron_test, Dayron.Repo, [])
    msg = "missing :url configuration in config :dayron_test, Dayron.Repo"
    assert_raise ArgumentError, msg, fn ->
      Config.get(Dayron.Repo, :dayron_test)
    end
  end

  test "raises an exception if url is invalid in config" do
    Application.put_env(:dayron_test, Dayron.Repo, [url: "invalid-url"])
    msg = ~r/invalid URL for :url configuration in config :dayron_test/
    assert_raise ArgumentError, msg, fn ->
      Config.get(Dayron.Repo, :dayron_test)
    end
  end

  test "returns application logger config" do
    Application.put_env(:dayron_test, Dayron.Repo, [url: "http://api.example.com", logger: MyLogger])
    {_, _, logger} = Config.parse(Dayron.Repo, otp_app: :dayron_test)
    assert logger == MyLogger
  end

  defmodule MyModel do
    use Dayron.Model, resource: "resources"

    defstruct name: "", age: 0
  end

  test "returns a valid request url" do
    config = Config.get(Dayron.Repo, :dayron_test)
    url = Config.get_request_url(config, MyModel, id: 1)
    assert url == "http://api.example.com/resources/1"
  end

  test "accepts url from a system env" do
    System.put_env("API_URL", "http://stage-api.example.com")
    Application.put_env(:dayron_test, Dayron.Repo, url: {:system, "API_URL"})
    config = Config.get(Dayron.Repo, :dayron_test)
    url = Config.get_request_url(config, MyModel, id: 1)
    assert url == "http://stage-api.example.com/resources/1"
  end
end
