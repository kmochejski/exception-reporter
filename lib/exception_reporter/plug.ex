defmodule ExceptionReporter.Plug do
  alias ExceptionReporter.{Report, Utils}

  def create_report(conn, kind, reason, stack) do
    %Report{
      timestamp: Utils.format_date_time(:calendar.local_time),
      server: get_hostname,
      request: create_conn_env(conn),
      kind: kind,
      reason: reason,
      stack: stack
    }
  end

  def create_conn_env(conn) do
    conn = conn
      |> Plug.Conn.fetch_cookies
      |> Plug.Conn.fetch_query_params
    %{
      path: conn.request_path,
      method: conn.method,
      parameters: Utils.filter_parameters(conn.params, Application.get_env(:exception_reporter, :filter_parameters, [])),
      ip_address: Enum.join(Tuple.to_list(conn.remote_ip), "."),
      headers: upcase_header_names(conn.req_headers)
    }
  end

  defp upcase_header_names(req_headers) do
    for {name, value} <- req_headers do
      {String.upcase(name), value}
    end
  end

  def format_backtrace(stack) do
    for {module, function, arity, [file: file, line: line]} <- stack do
      "#{file}:#{line}: #{module}.#{function}/#{arity}"
    end
  end

  defp get_hostname do
    case :inet.gethostname do
      {:ok, hostname} ->
        hostname |> to_string
      _ ->
        "Unable to determine hostname"
    end
  end

  defmacro __using__(_env) do
    if is_supported_env? do
      quote do
        import ExceptionReporter.Plug
        use Plug.ErrorHandler

        defp handle_errors(_conn, %{reason: %FunctionClauseError{function: :do_match}} = ex) do
          nil
        end

        if :code.is_loaded(Phoenix) do
          defp handle_errors(_conn, %{reason: %Phoenix.Router.NoRouteError{}}) do
            nil
          end
        end

        defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
          report = create_report(conn, kind, reason, stack)
          ExceptionReporter.notify(report)
        end
      end
    end
  end

  defp is_supported_env? do
    Mix.env in Application.get_env(:exception_reporter, :supported_envs, [])
  end

end
