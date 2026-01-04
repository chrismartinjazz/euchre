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

# Display a grid in the terminal. Use Cell(contents:, justified:, width:) objects in a Grid(grid:, width:, border:)
# and optionally a Border(vertical:, horizontal: corner:). Render using grid.to_s (puts) or return an array of strings
# with grid.to_a. A Grid may be used as the contents: of a Cell.
module TerminalGrid
end
