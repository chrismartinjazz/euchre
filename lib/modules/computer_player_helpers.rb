# frozen_string_literal: true

require_relative '../constants'

# Helpers for Computer Player class and related classes.
module ComputerPlayerHelpers
  def announce(name, input, confirmation: false)
    string = input.is_a?(Array) ? input.join(' ') : input
    sleep(THINKING_TIME)
    puts "\n#{name}: #{string} #{'Press Enter to continue...' if confirmation}".strip
    gets if confirmation && THINKING_TIME != 0
  end
end
