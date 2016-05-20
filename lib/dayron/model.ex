defmodule Dayron.Model do
  @moduledoc """
  Defines the functions to convert a module into a Dayron Model.

  A Model provides a set of functionalities around mapping the external data
  into local structures.

  In order to convert an Elixir module into a Model, Dayron provides a
  `Dayron.Model` mixin, that requires a `resource` option and a struct
  defining the available fields.

  ## Example

      defmodule User do
        use Dayron.Model, resource: "users"

        defstruct name: "", age: 0
      end

  The `resource` option value defines the complete API URL when requesting
  this model. For the above example, api calls will be made to
  http://YOUR_API_URL/users.

  Given an module with Ecto.Schema already included, the `Dayron.Model` mixin
  will include everything required for Dayron.Repo to get and send data to the
  external Rest Api. The `schema` will be used to map external api responses
  data to local structs.

  ## Example

      defmodule User do
        use Ecto.Schema
        use Dayron.Model

        schema "users" do
          field :name, :string
          field :age, :integer, default: 0
        end
      end

  In that case, resource name is defined based on the schema source name, or
  "users" in the above example. To replace the value, inform a `resource`
  option when including the mixin.

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

  ## Example

      def __from_json__(data, _options) do
        updated_data =
          data
          |> Map.get(:details)
          |> Map.delete(:type)
        struct(__MODULE__, updated_data)
      end

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

      def __url_for__([{:id, id} | _]), do: "/#{__resource__}/#{id}"

      def __url_for__(_), do: "/#{__resource__}"

      def __from_json__(data, _opts), do: struct(__MODULE__, data)

      def __from_json_list__(data, opts) when is_list(data) do
        Enum.map(data, &__from_json__(&1, opts))
      end

      def __from_json_list__(data, _opts), do: struct(__MODULE__, data)

      defoverridable [__url_for__: 1, __from_json__: 2]
    end
  end

  @doc """
  A shortcut for Requestable.url_for/2
  """
  def url_for(module, opts \\ []) do
    Requestable.url_for(module, opts)
  end

  @doc """
  A shortcut for Requestable.from_json/3
  """
  def from_json(module, data, opts \\ []) do
    Requestable.from_json(module, data, opts)
  end

  @doc """
  A shortcut for Requestable.from_json_list/3
  """
  def from_json_list(module, data, opts \\ []) do
    Requestable.from_json_list(module, data, opts)
  end
end
