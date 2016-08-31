defmodule <%= inspect module %>Test do
  use ExUnit.Case, async: true

  test "returns a valid url" do
    assert Dayron.Model.url_for(<%= inspect module %>) == "/<%= resource %>"
    assert Dayron.Model.url_for(<%= inspect module %>, id: "id") == "/<%= resource %>/id"
  end

  test "returns a populated struct" do
    struct = Dayron.Model.from_json(<%= inspect module %>, %{<%= Enum.map(params, fn {k, v} -> "#{k}: #{inspect v}" end) |> Enum.join(", ")%>})
    assert %<%=inspect module %>{} = struct
<%= for {k, v} <- params do %>    assert struct.<%= k %> == <%= inspect v %>
<% end %>  end
end
