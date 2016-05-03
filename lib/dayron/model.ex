defmodule Dayron.Model do
  @moduledoc """
  Defines the functions to convert a module into a Dayron Model.

  Given an module with Ecto.Schema included, the macro will include everything
  required for Dayron.Repo and Dayron.Client to get and send data to the
  external Rest Api. The Schema definition is required to convert the api
  response json to a valid struct, mapping the json attributes to fields.

  ## Example

      defmodule User do
        use Ecto.Schema
        use Dayron.Model

        schema "users" do
          field :name, :string
          field :age, :integer, default: 0
        end
      end

  By default the resource name is defined based on the schema source name, in
  the above example "users", to api calls will be made to http://YOUR_API_URL/
  users. In order to replace this, a :resource option is available.

  ## Example

      defmodule User do
        use Ecto.Schema
        use Dayron.Model, resource: "people"

        schema "users" do
          field :name, :string
          field :age, :integer, default: 0
        end
      end

  If some pre-processing is required to convert the json data into the struct,
  it's possible to override __from_json__/2 into the module.
  """
  alias Dayron.Requestable

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @resource opts[:resource]

      def __resource__ do
        case @resource do
          nil -> apply(__MODULE__, :__schema__, [:source])
          resource -> resource
        end
      end

      def __url_for__([id: id]), do: "/#{__resource__}/#{id}"

      def __url_for__(_), do: "/#{__resource__}"

      def __from_json__(data, _opts), do: struct(__MODULE__, data)

      def __from_json_list__(data, opts) when is_list(data) do
        Enum.map(data, &__from_json__(&1, opts))
      end

      def __from_json_list__(data, _opts), do: struct(__MODULE__, data)

      defoverridable [__url_for__: 1, __from_json__: 2]
    end
  end

  def url_for(module, opts \\ []) do
    Requestable.url_for(module, opts)
  end

  def from_json(module, data, opts \\ []) do
    Requestable.from_json(module, data, opts)
  end

  def from_json_list(module, data, opts \\ []) do
    Requestable.from_json_list(module, data, opts)
  end
end
