defmodule ExceptionReporter.EmailComposerTest do
  use ExUnit.Case
  alias ExceptionReporter.EmailComposer
  alias ExceptionReporter.Report

  test "compose/1" do
    report = %Report{
      timestamp: "2016-03-11 11:12:05",
      server: "server1",
      request: %{
        path: "/force-bug",
        method: "GET",
        parameters: %{"foo" => "bar"},
        ip_address: "127.0.0.1",
        headers: [{"DNT", "1"}, {"COOKIE", "cookie-cv"}]
      },
      kind: :error,
      reason: %RuntimeError{message: "Forced bug. Really long messages are sliced to 32 characters."},
      stack: [{ExceptionReporter.EmailComposerTest.App, :"-do_match/4-fun-0-", 1, [file: 'test/exception_reporter/email_composer_test.exs', line: 26]}]
    }
    expected_email = """
    Subject: [server1] (RuntimeError) Forced bug. Reall

    -------------------------------
    Exception banner
    -------------------------------
    ** (RuntimeError) Forced bug. Really long messages are sliced to 32 characters.
    -------------------------------
    Request:
    -------------------------------
    * Path       : /force-bug
    * HTTP Method: GET
    * IP address : 127.0.0.1
    * Parameters : %{"foo" => "bar"}
    * Timestamp  : 2016-03-11 11:12:05
    * Server     : server1

    -------------------------------
    Environment:
    -------------------------------
    * DNT   : 1
    * COOKIE: cookie-cv

    -------------------------------
    Backtrace:
    -------------------------------
        test/exception_reporter/email_composer_test.exs:26: anonymous fn/1 in ExceptionReporter.EmailComposerTest.App.do_match/4
    """

    assert rstrip_all_lines(expected_email) == rstrip_all_lines(EmailComposer.compose(report))
  end

  test "compose/1 when report contains default values" do
    report = %Report{}
    expected_email = """
    Subject: []
    -------------------------------
    Exception banner
    -------------------------------

    -------------------------------
    Request:
    -------------------------------
    * Path       :
    * HTTP Method:
    * IP address :
    * Parameters : %{}
    * Timestamp  :
    * Server     :

    -------------------------------
    Environment:
    -------------------------------

    -------------------------------
    Backtrace:
    -------------------------------
    """

    assert rstrip_all_lines(expected_email) == rstrip_all_lines(EmailComposer.compose(report))
  end

  defp rstrip_all_lines(str) do
    str
    |> String.split("\n")
    |> Enum.filter_map(&(String.length(&1) > 0), &String.rstrip/1)
    |> Enum.join("\n")
  end

end
