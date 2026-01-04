# frozen_string_literal: true

# Text graphics used in the display
require_relative 'terminal_display/graphics'

# Classes to display different sections of the game screen
require_relative 'terminal_display/display_players'
require_relative 'terminal_display/display_score'
require_relative 'terminal_display/display_tricks'

# The core Display class that orchestrates Display messages.
require_relative 'terminal_display/display'

# Display the Euchre game in the terminal
module TerminalDisplay
end
