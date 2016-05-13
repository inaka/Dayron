defmodule Dayron.NoResultsError do
  @moduledoc """
  Raised at runtime when the request does not return any result.
  """
  defexception [:request]

  def message(%{request: request}) do
    """
    expected at least one result but got none in request:

    #{inspect request, pretty: true}
    """
  end
end


defmodule Dayron.ServerError do
  @moduledoc """
  Raised at runtime when the request returns an error.
  """
  defexception [:request, :response]

  def message(%{request: request, response: response}) do
    """
    unexpected response error in request:

    #{inspect request, pretty: true}

    * Server Error

    #{inspect response}
    """
  end
end

defmodule Dayron.ClientError do
  @moduledoc """
  Raised at runtime when the request connection fails.
  """
  defexception [:id, :reason, :request]

  def message(%{request: request, reason: reason}) do
    """
    unexpected client error in request:

    #{inspect request, pretty: true}

    * Reason: #{inspect reason}
    """
  end
end


defmodule Dayron.ValidationError do
  @moduledoc """
  Raised at runtime when the response is a 422 unprocessable entity.
  """
  defexception [:request, :response]

  def message(%{request: request, response: response}) do
    """
    validation error in request:

    #{inspect request, pretty: true}

    * Response:

    #{inspect response}
    """
  end
end
