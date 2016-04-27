defmodule ExceptionReporter.UtilsTest do
  use ExUnit.Case
  alias ExceptionReporter.Utils

  test "Filters parameters" do
    params = %{"client" => "demo", "credentials" => [%{"kind" => "STATIC_LOGIN", "value" => "test"}], "sessionId" => "1", "sessionIdSignature" => "6e203cf"}
    filter_parameters = ["value", "sessionIdSignature"]
    assert Utils.filter_parameters(params, filter_parameters) == %{"client" => "demo", "credentials" => [%{"kind" => "STATIC_LOGIN", "value" => "[FILTERED]"}], "sessionId" => "1", "sessionIdSignature" => "[FILTERED]"}
  end

  test "Formats date and time" do
    date_time = {{2016, 3, 9}, {8, 1, 55}}
    assert Utils.format_date_time(date_time) == "2016-03-09 08:01:55"
  end

  test "Returns the length of the longest first element in the list of tuples" do
    list_of_tuples = [{"content-type", "text/plain"}, {"content-length", "15"}, {"dnt", "1"}]
    assert Utils.max_key_length(list_of_tuples) == 14
  end

  test "Pads right" do
    assert Utils.pad_right("abc", 5) == "abc  "
    assert Utils.pad_right("ąbć", 5) == "ąbć  "
    assert Utils.pad_right("abc", 2) == "abc"
  end

end
