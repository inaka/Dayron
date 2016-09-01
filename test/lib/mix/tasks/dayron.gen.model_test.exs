defmodule Mix.Tasks.Phoenix.Gen.ModelTest do
  use ExUnit.Case
  import MixHelper

  setup do
    Mix.Task.clear
    :ok
  end

  test "generates a model" do
    in_tmp "generates a model", fn ->
      Mix.Tasks.Dayron.Gen.Model.run ["User", "users", "name", "age:integer", "nicks:array",
                                       "famous:boolean", "bank_balance:float", "desc:string"]

      assert_file "lib/dayron/models/user.ex", fn file ->
        assert file =~ "defmodule Dayron.User do"
        assert file =~ "use Dayron.Model, resource: \"users\""
        assert file =~ "defstruct name: \"\", age: 0, nicks: [], famous: false, bank_balance: 0.0, desc: \"\""
        assert file =~ "end"
      end

      assert_file "test/dayron/models/user_test.exs", fn file ->
        assert file =~ "defmodule Dayron.UserTest do"
        assert file =~ "use ExUnit.Case, async: true"
        assert file =~ "test \"returns a valid url\" do"
        assert file =~ "assert Dayron.Model.url_for(Dayron.User) == \"/users\""
        assert file =~ "assert Dayron.Model.url_for(Dayron.User, id: \"id\") == \"/users/id\""
        assert file =~ "end"
        assert file =~ "test \"returns a populated struct\" do"
        assert file =~ "struct = Dayron.Model.from_json(Dayron.User, %{name: \"some content\", age: 128, nicks: [1], famous: true, bank_balance: 128.1, desc: \"some content\"})"
        assert file =~ "assert %Dayron.User{} = struct"
        assert file =~ "assert struct.name == \"some content\""
        assert file =~ "assert struct.age == 128"
        assert file =~ "assert struct.nicks == [1]"
        assert file =~ "assert struct.famous == true"
        assert file =~ "assert struct.bank_balance == 128.1"
        assert file =~ "struct.desc == \"some content\""
      end
    end
  end

  test "generates nested model" do
    in_tmp "generates nested model", fn ->
      Mix.Tasks.Dayron.Gen.Model.run ["Admin.User", "users", "name:string"]

      assert_file "lib/dayron/models/admin/user.ex"
      assert_file "test/dayron/models/admin/user_test.exs"
    end
  end

  test "uses the :models_path and :models_test_path configs" do
    in_tmp "uses the :models_path and :models_test_path configs", fn ->

      with_generator_env [models_path: "web/models", models_test_path: "test/models"], fn ->
        Mix.Tasks.Dayron.Gen.Model.run ["User", "users", "name:string"]

        assert_file "web/models/user.ex"
        assert_file "test/models/user_test.exs"
      end

    end
  end

  test "raises when invalid attributes are provided" do
    assert_raise Mix.Error, "Unknown type `foo` given to generator", fn ->
      Mix.Tasks.Dayron.Gen.Model.run ["User", "users", "name:foo"]
    end
  end

  test "raises with help when invalid args are provided" do
    assert_raise Mix.Error, ~r/mix dayron.gen.model expects both the model name and the resource path/, fn ->
      Mix.Tasks.Dayron.Gen.Model.run ["User", "name:string"]
    end
  end

  test "raises with help when no args are provided" do
    assert_raise Mix.Error, ~r/mix dayron.gen.model expects both the model name and the resource path/, fn ->
      Mix.Tasks.Dayron.Gen.Model.run []
    end
  end

end
