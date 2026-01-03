# frozen_string_literal: true

module Euchre
  module TerminalGrid
    # Generates a text representation of a Grid of Cells.
    class GridRenderer
      def initialize
        @justify_text = JustifyText.new
      end

      def render(grid_context:)
        rows(grid_context: grid_context).join("\n")
      end

      def rows(grid_context:)
        return nil if grid_context.grid.nil?

        borders_required = grid_context.border.horizontal.length.positive?

        my_rows = []
        my_rows.push(border_row(0, grid_context, top_row: true)) if borders_required

        grid_context.grid.each_with_index do |grid_row, grid_row_index|
          grid_row_array = build_grid_row_array(grid_row, grid_row_index, grid_context)
          grid_row_array.push(border_row(grid_row_index, grid_context)) if borders_required
          my_rows.concat(grid_row_array)
        end
        my_rows
      end

      private

      def build_grid_row_array(grid_row, grid_row_index, grid_context)
        grid_rows = []
        grid_context.row_heights[grid_row_index].times do |cell_row_index|
          row = build_cell_row(grid_row, grid_row_index, cell_row_index, grid_context)
          grid_rows.append(row)
        end

        grid_rows
      end

      def build_cell_row(grid_row, grid_row_index, cell_row_index, grid_context)
        current_row_col_widths = grid_context.col_widths[grid_row_index]
        row_parts = [grid_context.border.vertical]
        row_parts += grid_row.map.with_index do |cell, grid_col_index|
          width = current_row_col_widths[grid_col_index]
          next if width.zero?

          @justify_text.justify(
            text: cell.contents[cell_row_index],
            justified: cell.justified,
            width: width,
            border: grid_context.border
          )
        end
        row_parts.join
      end

      def border_row(grid_row_index, grid_context, top_row: false)
        current_row_corners = [0] + cumulative_sum(grid_context.col_widths[grid_row_index])
        next_row_corners = if grid_context.grid[grid_row_index + 1].nil? || top_row
                             []
                           else
                             cumulative_sum(grid_context.col_widths[grid_row_index + 1])
                           end
        corners = current_row_corners.concat(next_row_corners).uniq.sort
        border_with_corners(corners, grid_context)
      end

      def cumulative_sum(array)
        sum = 0
        array.map { |i| sum += i }
      end

      def border_with_corners(corners, grid_context)
        corners_required = grid_context.border.corner.length.positive?
        row = grid_context.border.horizontal * grid_context.width
        corners.each { |corner| row[corner] = grid_context.border.corner } if corners_required
        row
      end
    end
  end
end
