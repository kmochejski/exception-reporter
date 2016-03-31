defmodule ExceptionReporter.Utils do

  @filtered "[FILTERED]"

  def filter_parameters(%{} = map, filter_list) do
    map
    |> Enum.into(%{}, fn {key, value} ->
      if is_binary(key) && key in filter_list do
        {key, @filtered}
      else
        {key, filter_parameters(value, filter_list)}
      end
    end)
  end

  def filter_parameters([_|_] = list, filter_list) do
    list
    |> Enum.map(&filter_parameters(&1, filter_list))
  end

  def filter_parameters(other, _filter_list), do: other

  def format_date_time({{year, month, day}, {hour, minute, second}}) do
    :io_lib.format("~4..0B-~2..0B-~2..0B ~2..0B:~2..0B:~2..0B", [year, month, day, hour, minute, second])
    |> List.flatten
    |> to_string
  end

  def max_key_length(list_of_tuples) do
    list_of_tuples
    |> Enum.reduce(0, fn {key, _}, max ->
      case String.length(key) do
        len when len > max ->
          len
        _ ->
          max
      end
    end)
  end

  def pad_right(s, max_len) do
    case String.length(s) do
      len when len < max_len ->
        pad_right(s <> " ", max_len)
      _ ->
        s
    end
  end

end
