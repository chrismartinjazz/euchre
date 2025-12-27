# frozen_string_literal: true

# Constants
require_relative 'display_terminal_grid/constants'

# Cell and Border
require_relative 'display_terminal_grid/cell'
require_relative 'display_terminal_grid/border'

# Justify Text helper
require_relative 'display_terminal_grid/justify_text'

# Grid
require_relative 'display_terminal_grid/grid_context'
require_relative 'display_terminal_grid/grid_validator'
require_relative 'display_terminal_grid/grid_layout'
require_relative 'display_terminal_grid/grid_renderer'
require_relative 'display_terminal_grid/grid'

# Display a grid in the terminal
module DisplayTerminalGrid
end
