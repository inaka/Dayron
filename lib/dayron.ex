defmodule Dayron do
  @moduledoc ~S"""
  Dayron is split into 2 main components:

    * `Dayron.Repo` - repositories are wrappers around HTTP clients.
      Via the repository, we can send requests to external REST APIs,
      performing actions to get, create, update or destroy resources.
      A repository needs an adapter and the api URL. HTTPoison is the default
      built-in adapter.

    * `Dayron.Model` - models allow developers to define structures
      that map the external resources into local data. It also implements
      callbacks to handle specific configuration, such as the resource name
      used by the request and the data mapping rules.

  In the following sections, we will provide an overview of those components
  and how they interact with each other. Feel free to access their respective
  module documentation for more specific examples, options and configuration.

  If you want to quickly check a sample application using Dayron, please check
  https://github.com/inaka/dayron/tree/master/examples/simple_blog.

  ## Repositories

  `Dayron.Repo` is a wrapper around a rest client. We can define a
  repository as follows:

      defmodule RestRepo do
        use Dayron.Repo, otp_app: :my_app
      end

  Where the configuration for the Repo must be in your application
  environment, usually defined in your `config/config.exs`:

      config :my_app, MyApp.RestRepo,
        url: "https://api.example.com",
        headers: [access_token: "token"]

  ## Model

  A Model provides a set of functionalities around mapping the external data
  into local structures.

  Let's see an User model example:

      defmodule User do
        use Dayron.Model, resource: "users"

        defstruct id: nil, name: "", age: 0
      end

  The model allows us to interact with the REST API using our repository:

      # Inserting a new user
      iex> user = %User{name: "User Name", age: 23}
      iex> RestRepo.insert!(User, user)
      {:ok, %User{...}}

      # Get the resource data back
      iex> user = RestRepo.get User, "user-id"
      %User{id: "user-id", ...}

      # Delete it
      iex> RestRepo.delete!(User, "user-id")
      {:ok, %User{...}}

  As an example, let's see how we could use the User Model above in
  a web application that needs to update users:

      def update(id, %{"user" => user_params}) do
        case RestRepo.update(User, id, user_params) do
          {:ok, user} ->
            send_resp conn, 200, "Ok"
          {:error, error} ->
            send_resp conn, 400, "Bad request"
        end
      end

  The Repo methods also accepts extra options. If you want to send a list of
  parameters to be sent in the query when retrieving a list of users, for
  example:

      iex> RestRepo.all(User, params: [name: "a user name"])
      [%User{...}, %User{...}]

  If you check the application logs, you'll see the complete request/response
  information:

      [debug] GET https://api.example.com/users
      Options:
        Params: name="a user name"
      Body: -
      Headers:
        access_token: "token"
      [debug] Response: 200 in 718ms

  For a complete list of avaliable options, please check `Dayron.Adapter`
  module.
  """
  use Application
  alias Mix.Project

  @version Project.config[:version]

  def version, do: @version

  def start(_, _), do: {:ok, self}
end
