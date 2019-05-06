defmodule BrainWeb.StripUTF8 do
  @doc """
    iex> StripUTF8.strip_utf "Tallak\xc3\xb1 Tveide"
    "Tallakñ Tveide"

	Gratefully stolen from user "tallakt" : https://elixirforum.com/t/force-encoding-to-utf8/1552/3

	Occasionally copying and pasting into an md file may lead to malformed UTF-8. The easiest way to handle it is simply to get rid of it.

  """
  def strip_utf(str) do
    strip_utf_helper(str, [])
  end

  defp strip_utf_helper(<<x :: utf8>> <> rest, acc) do
    strip_utf_helper rest, [x | acc]
  end

  defp strip_utf_helper(<<x>> <> rest, acc), do: strip_utf_helper(rest, acc)

  defp strip_utf_helper("", acc) do
    acc
    |> :lists.reverse
    |> List.to_string
  end
end
