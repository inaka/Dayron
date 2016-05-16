defmodule Dayron.Response do
  @moduledoc """
  Defines a struct to store the response data returned by an api request.
  """
  defstruct status_code: 0, body: nil, headers: [], elapsed_time: 0
  @type t :: %__MODULE__{status_code: non_neg_integer, body: binary,
                         headers: list, elapsed_time: non_neg_integer}
end

defimpl Inspect, for: Dayron.Response do
  @moduledoc """
  Implementing Inspect protocol for Dayron.Response
  It changes the output for pretty:true option

  ## Example:

      > inspect response, pretty: true
      Response: 200 in 200ms
  """
  import Inspect.Algebra
  
  def inspect(response, %Inspect.Opts{pretty: true}) do
    concat([
      "Response: ",
      to_string(response.status_code),
      " in ",
      formatted_time(response.elapsed_time)
    ])
  end
  def inspect(response, opts), do: Inspect.Any.inspect(response, opts)

  defp formatted_time(time) when time > 1000, do:
    concat [time |> div(1000) |> Integer.to_string, "ms"]
  defp formatted_time(time), do: concat [time |> Integer.to_string, "µs"]
end
