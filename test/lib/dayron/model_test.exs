defmodule Dayron.ModelTest do
  use ExUnit.Case, async: true
  alias Dayron.Model

  defmodule MyModel do
    use Dayron.Model, resource: "resources"

    defstruct name: "", age: 0
  end

  test "returns a valid url" do
    assert Model.url_for(MyModel) == "/resources"
    assert Model.url_for(MyModel, id: "id") == "/resources/id"
  end

  test "returns a populated struct" do
    struct = Model.from_json(MyModel, %{name: "Full Name", age: 30})
    assert %MyModel{} = struct
    assert struct.name == "Full Name"
    assert struct.age == 30
  end

  defmodule MyEctoModel do
    use Dayron.Model

    defstruct name: "", age: 0

    def __schema__(:source), do: "resources"

    def __from_json__(data, _opts) do
      struct(__MODULE__, Map.merge(data, %{age: 40}))
    end

    def __url_for__([id: id]), do: "/#{__resource__}/all?id=#{id}"
    def __url_for__([]), do: "/#{__resource__}/all"
  end

  test "returns a valid url for db model using Ecto.__schema__ method" do
    assert Model.url_for(MyEctoModel) == "/resources/all"
  end

  test "returns a valid url for db model using overridden __url_for__" do
    assert Model.url_for(MyEctoModel, id: "id") == "/resources/all?id=id"
  end

  test "returns a populated struct with overridden __from_json__" do
    struct = Model.from_json(MyEctoModel, %{name: "Full Name"})
    assert %MyEctoModel{} = struct
    assert struct.name == "Full Name"
    assert struct.age == 40
  end

  defmodule MyInvalidModel do
    defstruct name: "", age: 0

    def __schema__(:source), do: "resources"
  end

  test "raises on protocol exception on url_for" do
    msg = ~r/the given module is not a Dayron.Model/
    assert_raise Protocol.UndefinedError, msg, fn -> 
      Model.url_for(MyInvalidModel)
    end
  end

  test "raises on protocol exception on from_json" do
    msg = ~r/the given module is not a Dayron.Model/
    assert_raise Protocol.UndefinedError, msg, fn -> 
      Model.from_json(MyInvalidModel, %{name: "Full Name"})
    end
  end

  test "raises on protocol exception on from_json_list" do
    msg = ~r/the given module is not a Dayron.Model/
    assert_raise Protocol.UndefinedError, msg, fn -> 
      Model.from_json_list(MyInvalidModel, [%{name: "Full Name"}])
    end
  end
end
