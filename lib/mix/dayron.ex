defmodule Mix.Dayron do
  # Conveniences for Dayron tasks.
  @moduledoc false

  @valid_attributes [:array, :integer, :float, :boolean, :string]

  @doc """
  Parses the attrs as received by generators.
  """
  def attrs(attrs) do
    Enum.map(attrs, fn attr ->
      attr
      |> String.split(":", parts: 2)
      |> list_to_attr()
      |> validate_attr!()
    end)
  end

  @doc """
  Returns a default value for the given type
  """
  def type_to_default(t) do
    case t do
      :array    -> []
      :integer  -> 0
      :float    -> 0.0
      :boolean  -> false
      :string   -> ""
    end
  end

  @doc """
  Returns a default test value for the given type
  """
  def type_to_test_value(t) do
    case t do
      :array    -> [1]
      :integer  -> 128
      :float    -> 128.1
      :boolean  -> true
      :string   -> "some content"
    end
  end

  @doc """
  Checks the availability of a given module name.
  """
  def check_module_name_availability!(name) do
    name = Module.concat(Elixir, name)
    if Code.ensure_loaded?(name) do
      Mix.raise "Module name #{inspect name} is already taken, please choose another name"
    end
  end

  @doc """
  Returns the module base name based on the configuration value.

      config :my_app
        namespace: My.App

  If there's no namespace defined for this app, returns the camelized otp app name
  """
  def base do
    app = otp_app

    case Application.get_env(app, :namespace, app) do
      ^app -> app |> to_string |> Macro.camelize
      mod  -> mod |> inspect
    end
  end

  @doc """
  Returns the otp app from the Mix project configuration.
  """
  def otp_app do
    Mix.Project.config |> Keyword.fetch!(:app)
  end

  defp list_to_attr([key]), do: {String.to_atom(key), :string}
  defp list_to_attr([key, value]), do: {String.to_atom(key), String.to_atom(value)}

  defp validate_attr!({_name, type} = attr) when type in @valid_attributes, do: attr
  defp validate_attr!({_, type}), do: Mix.raise "Unknown type `#{type}` given to generator"
end
