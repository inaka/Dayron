defmodule Dayron.ConfigTest do
  use ExUnit.Case, async: true
  alias Dayron.Config

  setup do
    Application.put_env(:dayron_test, Dayron.Repo, 
      url: "http://api.example.com",
      headers: [access_token: "token"]
    )
  end

  test "parses a valid config" do    
    {otp_app, adapter, config} = Config.parse(Dayron.Repo, otp_app: :dayron_test)
    assert otp_app == :dayron_test
    assert adapter == Dayron.HTTPoisonAdapter
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
end
