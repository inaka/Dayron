defmodule Dayron.NoResultsError do
  @moduledoc """
  Raised at runtime when the request does not return any result.
  """
  defexception [:url, :method]

  def message(%{url: url, method: method}) do
    """
    expected at least one result but got none in request:

    #{method} #{url}
    """
  end
end


defmodule Dayron.ServerError do
  @moduledoc """
  Raised at runtime when the request returns an error.
  """
  defexception [:url, :method, :body]

  def message(%{url: url, method: method, body: body}) do
    """
    unexpected response error in request:

    #{method} #{url}

    * Server Error

    #{inspect body}
    """
  end
end

defmodule Dayron.ClientError do
  @moduledoc """
  Raised at runtime when the request connection fails.
  """
  defexception [:url, :method, :reason]

  def message(%{url: url, method: method, reason: reason}) do
    """
    unexpected client error in request:

    #{method} #{url}

    * Reason:

    #{inspect reason}
    """
  end
end


defmodule Dayron.ValidationError do
  @moduledoc """
  Raised at runtime when the response is a 422 unprocessable entity.
  """
  defexception [:url, :method, :response]

  def message(%{url: url, method: method, response: response}) do
    """
    validation error in request:

    #{method} #{url}

    * Response (422):

    #{inspect response}
    """
  end
end
