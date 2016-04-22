defmodule Dayron.Model do
  alias Dayron.Requestable

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @resource opts[:resource]

      def __resource__ do
        @resource || __schema__(:source)
      end
      
      def __url_for__([id: id]), do: "/#{__resource__}/#{id}"

      def __url_for__([]), do: "/#{__resource__}"

      def __from_json__(data, _opts), do: struct(__MODULE__, data)

      defoverridable [__url_for__: 1, __from_json__: 2]
    end
  end

  def url_for(module, opts \\ []) do
    Requestable.url_for(module, opts)
  end

  def from_json(module, data, opts \\ []) do
    Requestable.from_json(module, data, opts)
  end
end
