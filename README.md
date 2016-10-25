# Dayron

[![Build Status](https://travis-ci.org/inaka/Dayron.svg?branch=master)](https://travis-ci.org/inaka/Dayron)
[![Deps Status](https://beta.hexfaktor.org/badge/all/github/inaka/Dayron.svg)](https://beta.hexfaktor.org/github/inaka/Dayron)
[![Inline docs](https://inch-ci.org/github/inaka/Dayron.svg)](https://inch-ci.org/github/inaka/Dayron)
[![Coverage Status](https://coveralls.io/repos/github/inaka/Dayron/badge.svg?branch=master)](https://coveralls.io/github/inaka/Dayron?branch=master)
[![Twitter](https://img.shields.io/badge/twitter-@inaka-blue.svg?style=flat)](http://twitter.com/inaka)

Dayron is a flexible library to interact with RESTful APIs and map resources to Elixir data structures. It works _similar_ of [Ecto.Repo](https://github.com/elixir-lang/ecto) but, instead of retrieving data from a database, it has underlying http clients to retrieve data from external HTTP servers.

## Installation

1. Add Dayron to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:dayron, "~> 0.1"}]
  end
  ```

1. Ensure Dayron is started before your application:

  ```elixir
  def application do
    [applications: [:dayron]]
  end
  ```

1. Then run `mix deps.get` in your shell to fetch the dependencies.

## Getting Started

Dayron requires a configuration entry with at least the external `url` attribute:

  ```elixir
  # In your config/config.exs file
  config :my_app, MyApp.RestRepo,
    url: "http://api.example.com"
  ```

Then you must define `MyApp.RestRepo` somewhere in your application with:


  ```elixir
  # Somewhere in your application
  defmodule MyApp.RestRepo do
    use Dayron.Repo, otp_app: :my_app
  end
  ```

## Defining Models

### With modules and structs

Dayron Models are simple modules with `use Dayron.Model` to implement the required protocol. The `resource` option defines the path to be used by the HTTP client to retrieve data. A `struct` must be defined with `defstruct` to allow json responses mapping.

  ```elixir
  defmodule MyApp.User do
    # api requests to http://api.example.com/users
    use Dayron.Model, resource: "users"

    # struct defining model attributes
    defstruct name: "", age: 0
  end
  ```

### Reusing Ecto Models

Dayron Models can work together with Ecto Models, allowing data loading from Database and External APIs just selecting the desired Repo. The defined schema will be used by Dayron when parsing server responses. If no `resource` option is present, the schema `source` is used as resource name.

  ```elixir
  defmodule MyApp.User do
    use Ecto.Schema
    use Dayron.Model

    # dayron requests to http://api.example.com/users
    schema "users" do
      field :name, :string
      field :age, :integer, default: 0
    end
  end
  ```

## Retrieving Data

After defining the configuration and model, you are allowed to retrieve data from an external API in a similar way when compared to an Ecto Repo. The example below presents a `UsersController` where an `index` action retrieves a list of users from the server, and a `show` action retrieves a single `User`:

  ```elixir
  defmodule MyApp.UsersController do
    use MyApp.Web, :controller

    alias MyApp.User
    alias MyApp.RestRepo

    def index(conn, params)
      conn
      |> assign(:users, RestRepo.all(User))
      |> render("index.html")
    end

    def show(conn, %{"id" => id}) do
      case RestRepo.get(User, id) do
        nil  -> put_status(conn, :not_found)
        user -> render conn, "show.html", user: user
      end
    end
  ```

## Generating modules

You can generate Dayron modules using the task `dayron.gen.model`

`mix dayron.gen.model User users name age:integer`

The first argument is the module name followed by the resource path. The generated model will contain:

* a model file in lib/your_app/models
* a test file in test/your_app/models

Both the model and the test path can be configured using the Dayron ```generators```
config.

```elixir
config :dayron, :generators,
  models_path: "web/models",
  models_test_path: "test/models"
```

The model fields are given using `name:type` syntax
where types can be one of the following:

    :array, :integer, :float, :boolean, :string

Omitting the type makes it default to `:string`



## Extra Configuration

### Request Headers

Using the configuration you're allowed to set headers that will be sent on every HTTP request made by Dyron. In the configuration example below, the `access-token` header is sent on every request:

  ```elixir
  # In your config/config.exs file
  config :my_app, MyApp.Dayron,
    url: "https://api.example.com",
    headers: ["access-token": "my-api-token"]
  ```

### HTTP Client Adapter

Currently the adapters available are:
- [HTTPoisonAdapter](https://github.com/inaka/Dayron/blob/master/lib/dayron/adapters/httpoison_adapter.ex), which uses [HTTPoison](https://github.com/edgurgel/httpoison) and [hackney](https://github.com/benoitc/hackney) to manage HTTP requests
- [TeslaAdapter](https://github.com/inaka/Dayron/blob/master/lib/dayron/adapters/tesla_adapter.ex), which uses [Tesla](https://github.com/teamon/tesla) and [hackney](https://github.com/benoitc/hackney) to manage HTTP requests

**NOTE:** While the HTTPoison adapter accepts the `:stream_to` argument and passes it on to HTTPoison, streaming isn't very well supported yet as it's not handled by the adapter in a generic way. The Tesla adapter currently ignores the option. See [discussion in issue #54](https://github.com/inaka/Dayron/issues/54#issuecomment-253715077).

You can also create your own adapter implementing the [Dyron.Adapter](https://github.com/inaka/Dayron/blob/master/lib/dayron/adapter.ex) behavior, and changing the configuration to something like:

  ```elixir
  # In your config/config.exs file
  config :my_app, MyApp.Dayron,
    url: "https://api.example.com",
    adapter: MyDayronAdapter
  ```

## Important links

  * [Online Documentation](http://hexdocs.pm/dayron)
  * [Examples](https://github.com/inaka/Dayron/tree/master/examples)

## Contributing

Pull request are very wellcome, but before opening a new one, please [open an issue](https://github.com/inaka/Dayron/issues/new) first.

If you want to send us a pull request, get the project working in you local:

  ```
  $ git clone https://github.com/inaka/Dayron.git
  $ cd Dayron
  $ mix deps.get
  $ mix test
  ```

Create a branch with the issue name and once you're ready (new additions and tests passing), submit your pull request!

## Building docs

  ```
  $ MIX_ENV=docs mix docs
  ```

## Contact Us

For **questions** or **general comments** regarding the use of this library, please use our public [hipchat room](http://inaka.net/hipchat).

If you find any **bugs** or have a **problem** while using this library, please [open an issue](https://github.com/inaka/Dayron/issues/new) in this repo (or a pull request).

You can also check all of our open-source projects at [inaka.github.io](https://inaka.github.io).

## Copyright and License

Copyright (c) 2016, Inaka.

Dayron source code is licensed under the [Apache 2 License](LICENSE).
