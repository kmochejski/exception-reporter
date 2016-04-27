defmodule ExceptionReporter.EmailComposer do
  require EEx
  alias ExceptionReporter.{Report, Utils}

  @max_subject_length 32

  def compose(report = %Report{}) do
    compose_subject(report) <> "\n" <> compose_body(report)
  end

  defp compose_subject(report = %Report{}) do
    "Subject: [#{report.server}] " <> if Exception.exception?(report.reason) do
      Exception.format(report.kind, report.reason, [])
      |> String.replace(~r/^\*+\s+/, "")
      |> String.slice(0, @max_subject_length)
    else
      ""
    end
  end

  @body_template """
  -------------------------------
  Exception banner
  -------------------------------
  <%= if Exception.exception?(report.reason), do: Exception.format(report.kind, report.reason, []) %>

  -------------------------------
  Request:
  -------------------------------
  * Path       : <%= report.request.path %>
  * HTTP Method: <%= report.request.method %>
  * IP address : <%= report.request.ip_address %>
  * Parameters : <%= inspect report.request.parameters %>
  * Timestamp  : <%= report.timestamp %>
  * Server     : <%= report.server %>

  -------------------------------
  Environment:
  -------------------------------
  <% max_len = Utils.max_key_length(report.request.headers) %><%= for {name, value} <- report.request.headers do %>* <%= Utils.pad_right(name, max_len) %>: <%= value %>
  <% end %>
  -------------------------------
  Backtrace:
  -------------------------------
  <%= Exception.format_stacktrace(report.stack) %>
  """

  EEx.function_from_string(:def, :compose_body, @body_template, [:report])

end
