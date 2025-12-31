# frozen_string_literal: true

# Constants
require_relative 'terminal_grid/constants'

# Cell and Border
require_relative 'terminal_grid/cell'
require_relative 'terminal_grid/border'

# Justify Text helper
require_relative 'terminal_grid/justify_text'

# Grid
require_relative 'terminal_grid/grid_context'
require_relative 'terminal_grid/grid_validator'
require_relative 'terminal_grid/grid_layout'
require_relative 'terminal_grid/grid_renderer'
require_relative 'terminal_grid/grid'

# Display a grid in the terminal
module TerminalGrid
end
