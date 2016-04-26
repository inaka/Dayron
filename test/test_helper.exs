Code.require_file "support/test_repo.exs", __DIR__
ExUnit.start()
Application.ensure_all_started(:bypass)
