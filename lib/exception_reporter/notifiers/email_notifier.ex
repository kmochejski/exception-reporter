defmodule ExceptionReporter.Notifiers.EmailNotifier do
  use GenEvent
  import Logger, only: [warn: 1]

  alias ExceptionReporter.Report
  alias ExceptionReporter.Notifiers.EmailNotifier.Composer

  def init(name) do
    {:ok, configure(name)}
  end

  # Callbacks
  # def handle_event({:aaa, report = %Report{}}, %{sender: sender, recipients: recipients, smtp: relay_config} = state) do
  def handle_event({:report, report}, %{sender: sender, recipients: recipients, smtp: relay_config} = state) do
    try do
      send_email!(report, sender, recipients, relay_config)
    rescue
      e ->
        Logger.warn "Failed to send an email. Cause: #{Exception.message(e)}"
    end
    {:ok, state}
  end

  defp send_email!(%Report{} = report, sender, recipients, relay_config) do
    res = :gen_smtp_client.send_blocking({
      sender,
      recipients,
      Composer.compose(report)
    }, relay_config)
    case res do
      {:error, _, msg} ->
        raise "#{inspect msg}"
      {:error, reason} ->
        raise "#{inspect reason}"
      _ ->
        {:ok, res}
    end
  end

  defp configure(name) do
    opts = Application.get_env(:exception_reporter, name, [])
    smtp = Keyword.get(opts, :smtp, [])
    %{
      sender:     Keyword.get(opts, :sender, ""),
      recipients: Keyword.get(opts, :recipients, []),
      smtp: [
        relay:    Keyword.get(smtp, :relay, "whatever"),
        username: Keyword.get(smtp, :username, ""),
        password: Keyword.get(smtp, :password, ""),
        port:     Keyword.get(smtp, :port, 24),
        ssl:      Keyword.get(smtp, :ssl, false),
        tls:      Keyword.get(smtp, :tls, :never),
        auth:     Keyword.get(smtp, :auth, :never)
      ]
    }
  end

end
