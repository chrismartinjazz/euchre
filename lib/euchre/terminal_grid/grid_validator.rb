# frozen_string_literal: true

module Euchre
  module TerminalGrid
    # Parses the arguments supplied to a Grid
    class GridValidator
      def self.validate_width(width)
        return width if width.is_a?(Integer) && width.positive?

        raise ArgumentError('Grid.width must be a positive integer')
      end

      def self.validate_border(border)
        return border if border.is_a?(Border)

        raise ArgumentError('Grid.border must be a Border struct')
      end

      def self.validate_grid(grid)
        return grid if grid.nil? || (grid.is_a?(Array) && grid.all?(Array) && grid.all? { |row| row.all?(Cell) })

        raise ArgumentError('Grid.grid must be an array of arrays of Cell objects, or nil')
      end
    end
  end
end
