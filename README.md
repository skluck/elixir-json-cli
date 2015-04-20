## A simple json parser CLI - Demo Elixir App

**"My First Elixir Application"** - This is a simple demo app to explore how to create a command line application.


### Elixir ecosystem

- iex (repl)
- mix (build tool)
- hex (package manager)
- exUnit (unit testing)

### Commands

- `mix deps.get`
  > Download dependencies

- `iex -S mix`
  > Compile application into iex context

- `mix escript.build`
  > Elixir and Erlang code is compiled to beam application code. To make this code executable, escript must be generated
  > that embeds all elixir code to run from the shell. Only erlang must be installed to run this escript.

- `mix test`
  > Run unit tests

### Anatomy of an Elixir app

Relative from application root:

```
_build/
    dev/
    env2/
    prod/

config/
    config.exs

deps/

lib/
    application-name.ex

test/

mix.exs
mix.lock
```

- `_build/` (git ignored)
  > Contains compiled builds, separated by environment

- `config/`
  > Configuration files, main entrypoint `config.exs` and individual environments.

- `deps/` (git ignored)
  > Dependencies, Same as "vendor" for most languages

- `lib/`
  > Where your code goes. Includes application entrypoint `application-name.ex`.

- `test/`
  > Unit tests

- `mix.exs`
  > Build configuration. Also declare dependencies and tasks like composer, gulp, make, etc.

- `mix.lock`
  > Locked sources and dependencies
