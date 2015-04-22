defmodule JsonCLI do
    alias Poison.Parser
    alias Poison.SyntaxError
    alias Poison.Encoder

    def main(args) do
        args |> parse_args |> process |> output
    end

    def parse_args(args) do
        options = OptionParser.parse(args, [
            switches: [help: :boolean, path: :string]
        ])

        case options do
            {[help: true], _, _}      -> :help
            {[path: path], args, _}   -> parse_args(path, args)
            {_, args, _}              -> parse_args(nil, args)

            # No match
            _                         -> :help
        end
    end

    def parse_args(path, args) do
        case args do
            []      -> {:stdin, nil}
            [file]  -> {file, path}
        end
    end

    def process({:stdin, path}) do
        IO.puts "Hello, you are trying to parse stdin?"

        contents = IO.read(1)
        # WHAT IF NO STDIN?????

        if contents !== :eof do
            contents = contents <> IO.read(:all)
        end

        {parse_file(contents), path}

    end

    # process

    def process({file, path}) do
        IO.puts "Hello, you are trying to parse a file?"

        contents = case File.read(file) do
            {:ok, body}      -> body
            {:error, reason} -> bomb(reason, 2)
        end

        {parse_file(contents), path}

    end

    def process(:help) do
        bomb(:help)
    end

    # output

    def output({decoded_json, nil}) do
        decoded_json |> output
    end

    def output({decoded_json, path}) do
        dig(decoded_json, String.split(path, ".")) |> output
    end

    def output(decoded_json) do
        IO.puts Encoder.encode(decoded_json, [])
    end

    # dig

    def dig(decoded_json, []) do
        decoded_json
    end

    def dig(decoded_json, [head | path]) when is_map(decoded_json) do
        decoded_json = decoded_json[head]

        if decoded_json === nil do
            bomb("Invalid JSON Path: \"#{head}\" is missing")
        end

        if path !== [] and not is_map(decoded_json) do
            bomb("Invalid JSON Path: Expected \"#{head}\" to be map")
        end

        decoded_json |> dig(path)
    end

    # utilities

    def parse_file(encoded_json) do

        try do
            Parser.parse!(encoded_json)
        rescue
            exception in SyntaxError -> bomb("Invalid JSON: " <> exception.message, 3)
        end
    end

    def bomb(reason, exit_code \\ 1) do

        case reason do
            :enoent -> reason = "Error: File not found"
            :help   -> reason = help
            _       -> reason = "Error: #{reason}"
        end

        IO.puts reason
        System.halt(exit_code)
    end

    def help do
        """
        Usage:
            jsoncli [file]

          Options:
            --help               # Show this help message and quit.
            --path json_path     # Path to JSON object to render.

          Description:

            Parse a JSON file from stdin or passed in the command line, and render it back out.
            Optionally, if a path is provided, just that will be rendered.

            Invalid JSON or path not found will result in non-zero exit code.

        """
    end

end
