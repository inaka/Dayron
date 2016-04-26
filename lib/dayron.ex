defmodule Dayron do
  @moduledoc false
  use Application
  alias Mix.Project

  @version Project.config[:version]

  def version, do: @version

  def start(_, _), do: {:ok, self}
end
