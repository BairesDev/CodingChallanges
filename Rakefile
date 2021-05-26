# frozen_string_literal: true

desc 'Run batch with a sample file'
task :reward do
  require './lib/loader'

  require 'app/services/json_parser_service'
  require 'app/representers/rewards_representer'

  input = File.read(ARGV[1])

  # Parse the input
  parsed_input = JsonParserService.call(input)

  # Represent the parsed json
  response = RewardsRepresenter.show(parsed_input)

  puts "\n\n", response, "\n"
end
