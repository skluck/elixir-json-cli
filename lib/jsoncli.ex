defmodule JsonCLI do

    def main(args) do
        args |> parse_args |> process
    end

    def parse_args(args) do
        options = OptionParser.parse(args, [switches: [help: :boolean]])

        case options do
            {[help: true], _, _}      -> :help
            {[path: path], [], _}     -> {path, nil}
            {[path: path], [file], _} -> {path, file}
            {_, [], _}                -> {nil, nil}
            {_, [file], _}            -> {nil, file}

            # No match
            _                         -> :help
        end
    end

    def get_file(file) do
        if file !== nil do
            contents = case File.read(file) do
                {:ok, body}      -> body
                {:error, reason} -> bomb(reason, 2)
            end
        end

        if contents === nil do
            IO.puts "Trying stdin"
            contents = IO.read(1)
            #
            # WHAT IF NO STDIN?????
            #

            cond do
                contents !== :eof ->
                    contents = contents <> IO.read(:all)
                true ->
                    contents = nil
            end
        end

        if contents === nil do
            bomb("No stdin provided", 2)
        end

        contents
    end

    def process({path, file}) do
        IO.puts "Hello, you are trying to parse something?"

        json = get_file(file)

        parsed = case Poison.decode(json) do
            {:ok, value}       -> value
            _                  -> bomb("Invalid JSON could not be parsed", 3)
        end

    end

    def process(:help) do
        bomb(:help)
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
