defmodule Fastgoblin do

  defmodule ParseError do
    defexception [:message]
  end

  def parse_line(line) do
    case  line |> parse_tag("owner") do
      {owner, rest} ->
        {ownerRealm, _rest} = rest |> parse_tag("ownerRealm")
        {ownerRealm, owner}
      :error ->
        :error
    end
  end

  def parse(binary) when is_binary(binary) do
    binary
    |> String.split("\n")
    |> Enum.map(&parse_line(&1))
    |> Enum.reject(&(&1 == :error))
  end

  def parse_tag(line, tag) do
    case :binary.match(line, tag) do
      {pos, _} ->
        pos = pos + String.length(tag) + 3
        case line do
          <<_prefix::size(pos)-binary, rest::binary>> ->
            rest |> extract_string
          _ ->
            raise ParseError, "unexpected escape character in #{inspect line}"
        end
      :nomatch ->
        :error
    end

  end

  def extract_string(line) do
    case :binary.match(line, "\"") do
      {pos, _} ->
        pos = pos
        case line do
          <<string::size(pos)-binary, rest::binary>> ->
            {string, rest}
          _ ->
            raise ParseError, "unexpected character in #{inspect line}"
        end
      :nomatch ->
        raise ParseError, "unexpected character in #{inspect line}"
    end
  end
end
