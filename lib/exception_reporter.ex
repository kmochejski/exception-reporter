defmodule ExceptionReporter do
  alias ExceptionReporter.{EmailComposer, Report}
  import Logger

  def start(_, _) do
    {:ok, self}
  end

  def notify(%Report{} = report) do
    Task.start fn ->
      do_notify(report)
    end
  end

  defp do_notify(report = %Report{}) do
    %{sender: sender, recipients: recipients, smtp: relay_config} = read_email_notifier_config
    try do
      send_email!(report, sender, recipients, relay_config)
    rescue
      e ->
        Logger.error "Failed to send an email. Cause: #{Exception.message(e)}"
    end
  end

  defp read_email_notifier_config do
    %{
      sender:     Application.get_env(:exception_reporter, :sender, ""),
      recipients: Application.get_env(:exception_reporter, :recipients, []),
      smtp: [
        relay:    Application.get_env(:exception_reporter, :relay, "localhost"),
        username: Application.get_env(:exception_reporter, :username, ""),
        password: Application.get_env(:exception_reporter, :password, ""),
        port:     Application.get_env(:exception_reporter, :port, 25),
        ssl:      Application.get_env(:exception_reporter, :ssl, false),
        tls:      Application.get_env(:exception_reporter, :tls, :never),
        auth:     Application.get_env(:exception_reporter, :auth, :never)
      ]
    }
  end

  defp send_email!(report = %Report{}, sender, recipients, relay_config) do
    res = :gen_smtp_client.send_blocking({
      sender,
      recipients,
      EmailComposer.compose(report)
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

end
