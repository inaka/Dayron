defmodule Mix.Tasks.Dayron.Gen.Model do
  use Mix.Task

  @shortdoc "Generates a Dayron model"
  @template_folder "priv/templates/dayron.gen.model"

  @moduledoc """
  Generates an Dayron model in your application.

      mix dayron.gen.model User users name:string age:integer

  The first argument is the module name followed by the resource path

  The generated model will contain:

    * a model file in lib/your_app/models
    * a test file in test/your_app/models

  Both the model and the test path can be configured using the Dayron ```generators```
  config.

      config :dayron, :generators,
        models_path: "web/models",
        models_test_path: "test/models"

  ## Attributes

  The resource fields are given using `name:type` syntax
  where types can be one of the following:

      :array, :integer, :float, :boolean, :string

  Omitting the type makes it default to `:string`:

      mix dayron.gen.model User users name age:integer

  ## Namespaced resources

  Resources can be namespaced, for such, it is just necessary
  to namespace the first argument of the generator:

      mix dayron.gen.model Admin.User users name:string age:integer
  """
  def run(args) do
    {_, parsed, _} = OptionParser.parse(args)
    [module, resource | attrs] = validate_args!(parsed)

    attrs = Mix.Dayron.attrs(attrs)
    full_module_name = Module.concat(Mix.Dayron.base, module)
    Mix.Dayron.check_module_name_availability!(full_module_name)

    bindings = [module: full_module_name, resource: resource,
                struct_body: struct_body(attrs), params: test_params(attrs)]

    files = [{".ex", models_path()}, {"_test.exs", models_test_path()}]
    generate_files(files, module, bindings)
  end

  defp generate_files(files, module, bindings) do
    template_folder = Application.app_dir(:dayron, @template_folder)
    Enum.each(files, fn {ext, path} ->
      template = Path.join(template_folder, "model#{ext}")
      contents = EEx.eval_file(template, bindings)
      target   = Path.join(path, file_name(module, ext))
      Mix.Generator.create_file(target, contents)
    end)
  end

  defp validate_args!([_, resource | _] = args) do
    cond do
      String.contains?(resource, ":") ->
        raise_with_help
      true ->
        args
    end
  end

  defp validate_args!(_) do
    raise_with_help
  end

  defp raise_with_help do
    Mix.raise """
    mix dayron.gen.model expects both the model name and the resource path
    of the generated resource followed by any number of attributes:

        mix dayron.gen.model User users name:string
    """
  end

  defp struct_body(attrs) do
    Enum.map(attrs, fn {k, t} ->
     "#{Atom.to_string(k)}: #{inspect Mix.Dayron.type_to_default(t)}"
    end)
    |> Enum.join(", ")
  end

  defp test_params(attrs) do
    Enum.map(attrs, fn {k, t} ->
     {Atom.to_string(k), Mix.Dayron.type_to_test_value(t)}
    end)
  end

  defp models_path do
    config = Application.get_env(:dayron, :generators) || []
    Keyword.get(config, :models_path) || default_path("lib")
  end

  defp models_test_path do
    config = Application.get_env(:dayron, :generators) || []
    Keyword.get(config, :models_test_path) || default_path("test")
  end

  defp default_path(base) do
    app = Mix.Dayron.otp_app |> to_string
    Path.join([base, app, "models"])
  end

  defp file_name(module_name, ext) do
    String.split(module_name, ".")
      |> Enum.map(&Macro.underscore/1)
      |> Path.join
      |> Kernel.<>(ext)
  end
end
