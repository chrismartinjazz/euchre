# frozen_string_literal: true

module Euchre
  module TerminalGrid
    # Display a grid of cells in the terminal. Has a 'width' - rows can be less than the width, but will be truncated
    # if exceeding the width. Has a 'border' of type Border. Use #update or #update_cell to change the contents of
    # the grid. Call 'to_s' on the Grid to display it.
    class Grid
      attr_reader :grid_context

      def initialize(
        grid: nil,
        width: 80,
        border: Border.new(vertical: '|', horizontal: '-', corner: '+')
      )
        @grid_layout = GridLayout.new
        @grid_renderer = GridRenderer.new
        @grid_context = GridContext.new(
          width: GridValidator.validate_width(width),
          border: GridValidator.validate_border(border)
        )
        update(grid: grid)
      end

      def update(grid: @grid_context.grid, width: @grid_context.width, border: @grid_context.border)
        return nil if grid.nil?

        @grid_context.grid = GridValidator.validate_grid(grid) unless grid == @grid_context.grid
        @grid_context.width = GridValidator.validate_width(width) unless width == @grid_context.width
        @grid_context.border = GridValidator.validate_border(border) unless border == @grid_context.border
        @grid_layout.apply(grid_context: @grid_context)

        @grid_array = @grid_renderer.render(grid_context: @grid_context)
        @grid_string = @grid_array.join("\n")
      end

      def update_cell(cell:, row_index:, col_index:)
        my_grid = @grid_context.grid.map(&:dup)
        my_grid[row_index][col_index] = cell
        update(grid: my_grid)
      end

      def to_s
        @grid_string
      end

      def to_a
        @grid_array
      end
    end
  end
end
