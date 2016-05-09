defmodule Dayron.RepoTest do
  use ExUnit.Case, async: true
  require Dayron.TestRepo, as: TestRepo
  
  defmodule MyModel do
    use Dayron.Model, resource: "resources"

    defstruct id: nil, name: "", age: 0
  end

  # ================ GET ===========================
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

  test "get nil for timeout error" do
    assert nil == TestRepo.get(MyModel, "timeout-error")
  end

  test "get nil for connection error" do
    assert nil == TestRepo.get(MyModel, "connection-error")
  end

  test "does not accept direct Dayron.Repo.get call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.get(MyModel, "id")
    end
  end

  # ================ GET! ===========================
  test "get! a valid resource" do
    body = %{name: "Full Name", age: 30}
    assert %MyModel{name: "Full Name", age: 30} = TestRepo.get!(MyModel, "id", body: body)
  end

  test "raises an exception for not found resource" do
    assert_raise Dayron.NoResultsError, fn ->
      TestRepo.get!(MyModel, "invalid-id")
    end
  end

  test "raises an exception on request error" do
    msg = ~r/Internal Exception/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.get!(MyModel, "server-error")
    end
  end

  test "raises an exception on timeout error" do
    msg = ~r/connect_timeout/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.get!(MyModel, "timeout-error")
    end
  end

  test "raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.get!(MyModel, "connection-error")
    end
  end

  # ================ ALL ===========================
  test "`all` returns a list of valid resources" do
    body = [
      %{name: "First Resource", age: 30},
      %{name: "Second Resource", age: 40}
    ]
    [first, second | _] = TestRepo.all(MyModel, [body: body])
    assert %MyModel{name: "First Resource", age: 30} = first
    assert %MyModel{name: "Second Resource", age: 40} = second
  end

  test "`all` returns a list of resources with query params" do
    params = [{:q, "qu ery"}, {:page, 2}]
    assert [] = TestRepo.all(MyModel, params: params)
  end

  test "`all` resturns empty list for server error" do
    assert [] == TestRepo.all(MyModel, [error: "server-error"])
  end

  test "`all` returns empty list for timeout error" do
    assert [] == TestRepo.all(MyModel, [error: "connection-error"])
  end

  # ================ ALL! ===========================
  test "`all!` returns a list of valid resources" do
    body = [
      %{name: "First Resource", age: 30},
      %{name: "Second Resource", age: 40}
    ]
    [first, second | _] = TestRepo.all!(MyModel, [body: body])
    assert %MyModel{name: "First Resource", age: 30} = first
    assert %MyModel{name: "Second Resource", age: 40} = second
  end

  test "`all!` raises an exception on request error" do
    msg = ~r/Internal Exception/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.all!(MyModel, [error: "server-error"])
    end
  end

  test "`all!` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.all!(MyModel, [error: "connection-error"])
    end
  end

  # ================ INSERT ===========================
  test "`insert` creates a valid resource from a model" do
    data = %{name: "Full Name", age: 30}
    {:ok, %MyModel{} = model} = TestRepo.insert(MyModel, data)
    assert model.id == "new-model-id"
  end

  test "`insert` fails when creating a resource from an invalid model" do
    data = %{name: nil, age: 30}
    {:error, %{method: "POST", response: response}} = TestRepo.insert(MyModel, data)
    assert response[:error] == "name is required"
  end

  test "`insert` raises an exception on request error" do
    msg = ~r/Internal Exception/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.insert(MyModel, %{error: "server-error"})
    end
  end

  test "`insert` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.insert(MyModel, %{error: "connection-error"})
    end
  end

  # ================ INSERT! ===========================
  test "`insert!` creates a valid resource from a model" do
    data = %{name: "Full Name", age: 30}
    {:ok, model = %MyModel{}} = TestRepo.insert!(MyModel, data)
    assert model.id == "new-model-id"
  end

  test "`insert!` raises an exception when creating a resource from an invalid model" do
    data = %{name: nil, age: 30}
    msg = ~r/validation error/
    assert_raise Dayron.ValidationError, msg, fn ->
      TestRepo.insert!(MyModel, data)
    end
  end

  test "`insert!` raises an exception on request error" do
    msg = ~r/Internal Exception/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.insert!(MyModel, %{error: "server-error"})
    end
  end

  test "`insert!` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.insert!(MyModel, %{error: "connection-error"})
    end
  end
end
