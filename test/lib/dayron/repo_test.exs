# defmodule Dayron.RepoTest do
#   use ExUnit.Case, async: true
  
#   bypass = Bypass.open
#   Application.put_env(:dayron, Dayron.RepoTest.MyRepo, [url: "http://localhost:#{bypass.port}"])

#   defmodule MyRepo do
#     use Dayron.Repo, opt_app: :dayron
#   end

#   defmodule MyModel do
#     use Dayron.Model, resource: "resources"

#     defstruct name: "", age: 0
#   end

#   setup do
#     {:ok, bypass: bypass}    
#   end

#   test "get a valid resource", %{bypass: bypass} do
#     Bypass.expect bypass, fn conn ->
#       assert "/resources/id" == conn.request_path
#       assert "GET" == conn.method
#       Plug.Conn.resp(conn, 200, ~s<{"name": "Full Name", "age": 30}>)
#     end
#     assert %MyModel{name: "Full Name", age: 30} = MyRepo.get(MyModel, "id")
#   end

# end
