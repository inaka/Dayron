defmodule Dayron.RepoTest do
  use ExUnit.Case, async: true
  require Dayron.TestRepo, as: TestRepo
  
  defmodule MyModel do
    use Dayron.Model, resource: "resources"

    defstruct id: nil, name: "", age: 0
  end

  # ================ GET ===========================
  test "`get` a valid resource" do
    body = %{name: "Full Name", age: 30}
    assert %MyModel{name: "Full Name", age: 30} = TestRepo.get(MyModel, "id", body: body)
  end

  test "`get` nil for invalid resource" do
    assert nil == TestRepo.get(MyModel, "invalid-id")
  end

  test "`get` raises an exception on request error" do
    msg = ~r/unexpected response error/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.get(MyModel, "server-error")
    end
  end

  test "`get` raises an exception on timeout error" do
    msg = ~r/connect_timeout/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.get(MyModel, "timeout-error")
    end
  end

  test "`get` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.get(MyModel, "connection-error")
    end
  end

  test "`get` does not accept direct Dayron.Repo.get call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.get(MyModel, "id")
    end
  end

  # ================ GET! ===========================
  test "`get!` a valid resource" do
    body = %{name: "Full Name", age: 30}
    assert %MyModel{name: "Full Name", age: 30} = TestRepo.get!(MyModel, "id", body: body)
  end

  test "`get!` raises an exception for not found resource" do
    msg = ~r/expected at least one result/
    assert_raise Dayron.NoResultsError, msg, fn ->
      TestRepo.get!(MyModel, "invalid-id")
    end
  end

  test "`get!` raises an exception on request error" do
    msg = ~r/unexpected response error/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.get!(MyModel, "server-error")
    end
  end

  test "`get!` raises an exception on timeout error" do
    msg = ~r/connect_timeout/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.get!(MyModel, "timeout-error")
    end
  end

  test "`get!` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.get!(MyModel, "connection-error")
    end
  end

  test "`get!` does not accept direct Dayron.Repo.get! call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.get!(MyModel, "id")
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

  test "`all` raises an exception on request error" do
    msg = ~r/unexpected response error/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.all(MyModel, [error: "server-error"])
    end
  end

  test "`all` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.all(MyModel, [error: "connection-error"])
    end
  end

  test "`all` does not accept direct Dayron.Repo.all call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.all(MyModel)
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
    {:error, %{response: response}} = TestRepo.insert(MyModel, data)
    assert response.body[:error] == "name is required"
  end

  test "`insert` raises an exception on request error" do
    msg = ~r/unexpected response error/
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

  test "`insert` does not accept direct Dayron.Repo.insert call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.insert(MyModel, %{})
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
    msg = ~r/unexpected response error/
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

  test "`insert!` does not accept direct Dayron.Repo.insert! call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.insert!(MyModel, %{})
    end
  end

  # ================ UPDATE ===========================
  test "`update` a valid resource given model and data" do
    data = %{name: "Full Name", age: 30}
    {:ok, %MyModel{} = model} = TestRepo.update(MyModel, 'id', data)
    assert model.id == "updated-model-id"
  end

  test "`update` a valid resource fails when data is invalid" do
    data = %{name: nil, age: 30}
    {:error, %{request: request, response: response}} = TestRepo.update(MyModel, 'id', data)
    assert request.method == :patch
    assert response.status_code == 422
    assert response.body[:error] == "name is required"
  end

  test "`update` an invalid resource returns an error" do
    data = %{name: "Full Name", age: 30}
    assert {:error, %{request: request, response: response}} = TestRepo.update(MyModel, 'invalid-id', data)
    assert request.method == :patch
    assert response.status_code == 404
  end

  test "`update` raises an exception on request error" do
    msg = ~r/unexpected response error/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.update(MyModel, 'id', %{error: "server-error"})
    end
  end

  test "`update` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.update(MyModel, 'id', %{error: "connection-error"})
    end
  end

  test "`update` does not accept direct Dayron.Repo.update call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.update(MyModel, 'id', %{})
    end
  end

  # ================ UPDATE! ===========================
  test "`update!` a valid resource given a model and data" do
    data = %{name: "Full Name", age: 30}
    {:ok, model = %MyModel{}} = TestRepo.update!(MyModel, 'id', data)
    assert model.id == "updated-model-id"
  end

  test "`update!` raises an exception when data is an invalid model" do
    data = %{name: nil, age: 30}
    msg = ~r/validation error/
    assert_raise Dayron.ValidationError, msg, fn ->
      TestRepo.update!(MyModel, 'id', data)
    end
  end

  test "`update!` raises an exception when id is invalid" do
    data = %{name: "Full Name", age: 30}
    assert_raise Dayron.NoResultsError, fn ->
      TestRepo.update!(MyModel, 'invalid-id', data)
    end
  end

  test "`update!` raises an exception on request error" do
    msg = ~r/unexpected response error/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.update!(MyModel, 'id', %{error: "server-error"})
    end
  end

  test "`update!` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.update!(MyModel, 'id', %{error: "connection-error"})
    end
  end

  test "`update!` does not accept direct Dayron.Repo.update! call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.update!(MyModel, 'id', %{})
    end
  end

  # ================ DELETE ===========================
  test "`delete` a valid resource given model and id" do
    {:ok, %MyModel{} = model} = TestRepo.delete(MyModel, 'id')
    assert model.id == "deleted-model-id"
  end

  test "`delete` a valid resource fails when server returns 422" do
    assert {:error, %{status_code: 422}} = TestRepo.delete(MyModel, 'validation-error-id')
  end

  test "`delete` an invalid resource returns an error" do
    assert {:error, %{status_code: 404}} = TestRepo.delete(MyModel, 'invalid-id')
  end

  test "`delete` raises an exception on request error" do
    msg = ~r/unexpected response error/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.delete(MyModel, "server-error")
    end
  end

  test "`delete` raises an exception on timeout error" do
    msg = ~r/connect_timeout/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.delete(MyModel, "timeout-error")
    end
  end

  test "`delete` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.delete(MyModel, "connection-error")
    end
  end

  test "`delete` does not accept direct Dayron.Repo.delete call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.delete(MyModel, "id")
    end
  end

  # ================ DELETE! ===========================
  test "`delete!` a valid resource given a model and id" do
    {:ok, model = %MyModel{}} = TestRepo.delete!(MyModel, 'id')
    assert model.id == "deleted-model-id"
  end

  test "`delete!` raises an exception when data is an invalid model" do
    msg = ~r/validation error/
    assert_raise Dayron.ValidationError, msg, fn ->
      TestRepo.delete!(MyModel, 'validation-error-id')
    end
  end

  test "`delete!` raises an exception when id is invalid" do
    assert_raise Dayron.NoResultsError, fn ->
      TestRepo.delete!(MyModel, 'invalid-id')
    end
  end

  test "`delete!` raises an exception on request error" do
    msg = ~r/unexpected response error/
    assert_raise Dayron.ServerError, msg, fn ->
      TestRepo.delete!(MyModel, "server-error")
    end
  end

  test "`delete!` raises an exception on timeout error" do
    msg = ~r/connect_timeout/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.delete!(MyModel, "timeout-error")
    end
  end

  test "`delete!` raises an exception on connection error" do
    msg = ~r/econnrefused/
    assert_raise Dayron.ClientError, msg, fn ->
      TestRepo.delete!(MyModel, "connection-error")
    end
  end

  test "`delete!` does not accept direct Dayron.Repo.delete! call" do
    msg = ~r/Cannot call Dayron.Repo directly/
    assert_raise RuntimeError, msg, fn ->
      Dayron.Repo.delete!(MyModel, "id")
    end
  end
end
