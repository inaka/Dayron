# Dayron

[![Build Status](https://travis-ci.org/inaka/Dayron.svg?branch=master)](https://travis-ci.org/inaka/Dayron)
[![Inline docs](http://inch-ci.org/github/inaka/Dayron.svg)](http://inch-ci.org/github/inaka/Dayron)
[![Coverage Status](https://coveralls.io/repos/github/inaka/Dayron/badge.svg?branch=master)](https://coveralls.io/github/inaka/Dayron?branch=master)
[![Twitter](https://img.shields.io/badge/twitter-@inaka-blue.svg?style=flat)](http://twitter.com/inaka)

Dayron is a flexible library to interact with resources from REST APIs and map them to models in Elixir. It works _similar_ to [Ecto.Repo](https://github.com/elixir-lang/ecto) but, instead of retrieving data from a database, it has underlying http clients to retrieve data from external HTTP servers.

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

Currently the only adapter available is [HTTPoisonAdapter](https://github.com/inaka/Dayron/blob/master/lib/dayron/adapters/httpoison_adapter.ex), which uses [HTTPoison](https://github.com/edgurgel/httpoison) and [hackney](https://github.com/benoitc/hackney) to manage HTTP requests.

You can also create your own adapter implementing the [Dyron.Adapter](https://github.com/inaka/Dayron/blob/master/lib/dayron/adapter.ex) behavior, and changing the configuration to something like:

  ```elixir
  # In your config/config.exs file
  config :my_app, MyApp.Dayron,
    url: "https://api.example.com",
    adapter: MyDayronAdapter
  ```

## Important links

  * [Online Documentation](http://hexdocs.pm/Dayron)
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

You can also check all of our open-source projects at [inaka.github.io](inaka.github.io).

## Copyright and License

Copyright (c) 2016, Inaka.

Dayron source code is licensed under the [Apache 2 License](LICENSE).
