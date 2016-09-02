defmodule <%= inspect module %> do
  use Dayron.Model, resource: <%= inspect resource %>

  defstruct <%= struct_body %>
end
