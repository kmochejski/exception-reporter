defmodule ExceptionReporter do
  alias ExceptionReporter.Report

  def start_link(_args) do
    res = GenEvent.start_link(name: __MODULE__)
    case res do
      {:ok, pid} ->
        notifiers
        |> Enum.each(&register_notifier/1)
    end
    res
  end

  def notify(%Report{} = report) do
    GenEvent.notify(__MODULE__, {:report, report})
  end

  defp notifiers do
    Application.get_env(:exception_reporter, :notifiers, [])
  end

  defp register_notifier({notifier, name} = handler) do
    GenEvent.add_handler(__MODULE__, handler, name)
  end

end
