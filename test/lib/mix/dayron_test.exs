defmodule Mix.DayronTest do
  use ExUnit.Case, async: true

  test "base/0 returns the module base based on the Mix application" do
    assert Mix.Dayron.base == "Dayron"
    Application.put_env(:dayron, :namespace, Test.Sample.App)
    assert Mix.Dayron.base == "Test.Sample.App"
  after
    Application.delete_env(:dayron, :namespace)
  end

  test "attrs/1 defaults each type" do
    attrs = [
      "logins:array",
      "age:integer",
      "temp:float",
      "admin:boolean",
      "name:string"
    ]
    assert Mix.Dayron.attrs(attrs) == [
      logins: :array,
      age: :integer,
      temp: :float,
      admin: :boolean,
      name: :string
    ]
  end

  test "attrs/1 raises with an unknown type" do
    assert_raise(Mix.Error, "Unknown type `other` given to generator", fn ->
      Mix.Dayron.attrs(["other:other"])
    end)
  end

  test "type_to_default/1 defaults each type" do
    assert Mix.Dayron.type_to_default(:array) == []
    assert Mix.Dayron.type_to_default(:integer) == 0
    assert Mix.Dayron.type_to_default(:float) == 0.0
    assert Mix.Dayron.type_to_default(:boolean) == false
    assert Mix.Dayron.type_to_default(:string) == ""
  end

  test "type_to_test_value/1 defaults each type" do
    assert Mix.Dayron.type_to_test_value(:array) == [1]
    assert Mix.Dayron.type_to_test_value(:integer) == 128
    assert Mix.Dayron.type_to_test_value(:float) == 128.1
    assert Mix.Dayron.type_to_test_value(:boolean) == true
    assert Mix.Dayron.type_to_test_value(:string) == "some content"
  end

  test "check_module_name_availability!/1 raises with a duplicated module name" do
    assert_raise(Mix.Error, ~r/Module name Dayron is already taken, please choose another name/, fn ->
      Mix.Dayron.check_module_name_availability!(Dayron)
    end)
    Mix.Dayron.check_module_name_availability!(NotFound)
  end
end
