defmodule ExceptionReporter.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule App do
    use Plug.Router
    use ExceptionReporter.Plug

    plug :match
    plug :dispatch

    get "force-bug" do
      raise "Forced bug"
    end

  end

  @opts App.init([])

  test "/not-found" do
    conn = conn(:get, "/not-found")
    assert catch_error(App.call(conn, @opts)) in [:function_clause, %FunctionClauseError{arity: 4, function: :do_match, module: ExceptionReporter.PlugTest.App}]
  end

  test "create_conn_env/1" do
    conn = conn(:get, "/force-bug")
    expected_conn_env = %{
      path: "/force-bug",
      method: "GET",
      ip_address: "127.0.0.1",
      parameters: %{},
      headers: []
    }
    assert expected_conn_env == ExceptionReporter.Plug.create_conn_env(conn)
  end

  test "create_conn_env/1 collects headers" do
    conn = conn(:get, "/force-bug") |> put_req_header("dnt", "1")
    %{headers: headers} = ExceptionReporter.Plug.create_conn_env(conn)
    assert [{"DNT", "1"}] == headers
  end

  test "create_conn_env/1 filters out query parameters" do
    conn = conn(:get, "/force-bug?foo=foo&bar=bar")
    %{parameters: params} = ExceptionReporter.Plug.create_conn_env(conn)
    assert %{"foo" => "[FILTERED]", "bar" => "bar"} == params
  end

  test "create_conn_env/1 filters out body parameters, including nested ones" do
    conn = conn(:post, "/force-bug", %{"foo" => "foo", "bar" => %{"foo" => "foo"}, "baz" => [%{"foo" => "foo", "bar" => "bar"}, %{"baz" => "baz"}]})
    %{parameters: params} = ExceptionReporter.Plug.create_conn_env(conn)
    assert %{"foo" => "[FILTERED]", "bar" => %{"foo" => "[FILTERED]"}, "baz" => [%{"foo" => "[FILTERED]", "bar" => "bar"}, %{"baz" => "baz"}]} == params
  end

end
