defmodule Dayron.RepoTest do
  use ExUnit.Case, async: true
  require Dayron.TestRepo, as: TestRepo
  
  defmodule MyModel do
    use Dayron.Model, resource: "resources"

    defstruct name: "", age: 0
  end

  test "get a valid resource" do
    body = %{name: "Full Name", age: 30}
    assert %MyModel{name: "Full Name", age: 30} = TestRepo.get(MyModel, "id", body: body)
  end

  test "get nil for invalid resource" do
    assert nil == TestRepo.get(MyModel, "invalid-id")
  end

  test "get nil for server error" do
    assert nil == TestRepo.get(MyModel, "server-error")
  end


  test "does not accept direct Dayron.Repo.get call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.get(MyModel, "id")
    end
  end

end
