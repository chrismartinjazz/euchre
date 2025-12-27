# frozen_string_literal: true

module DisplayTerminalGrid
  # Calculates the row height (as a single array) and column widths (as a 2D array) of a Grid. Expects flex
  # columns to be indicated as width: :flex within relevant Cells.
  class GridLayout
    def apply(grid_context:)
      return nil if grid_context.grid.nil?

      grid_context.row_heights = calculate_row_heights(grid_context)
      grid_context.col_widths = calculate_col_widths(grid_context)
    end

    private

    def calculate_row_heights(grid_context)
      grid_context.grid.each_with_object([]) { |row, array| array.push(height_of_highest_cell_in(row)) }
    end

    def height_of_highest_cell_in(row)
      row.max_by { |cell| cell.contents.size }.contents.size
    end

    def calculate_col_widths(grid_context)
      grid_context.grid.each_with_object([]) do |row, array|
        widths, flex_cells_count = read_width_params_from_grid_row(row)
        flex_width = calculate_flex_width(widths, flex_cells_count, grid_context)
        normalized_widths = if row_is_narrower_than_grid?(widths, flex_cells_count, grid_context)
                              widths
                            else
                              normalize_widths(widths, flex_width, grid_context)
                            end
        array.push(normalized_widths)
      end
    end

    def read_width_params_from_grid_row(row)
      widths = row.map(&:width)
      flex_cells_count = widths.count(:flex)
      [widths, flex_cells_count]
    end

    def calculate_flex_width(widths, flex_cells_count, grid_context)
      set_widths = widths.sum { |width| width.is_a?(Integer) ? width : 0 }
      border_and_set_widths_total = grid_context.border.horizontal.length + set_widths
      (grid_context.width - border_and_set_widths_total) / [flex_cells_count, 1].max
    end

    def row_is_narrower_than_grid?(widths, flex_cells_count, grid_context)
      flex_cells_count.zero? && widths.sum < grid_context.width
    end

    def normalize_widths(widths, flex_width, grid_context)
      my_widths = widths.map { |width| width == :flex ? flex_width : width }
      my_widths[0] += grid_context.width - my_widths.sum if my_widths.sum < grid_context.width
      recursively_reduce_final_column(my_widths, grid_context) if my_widths.sum > grid_context.width
      my_widths
    end

    def recursively_reduce_final_column(my_widths, grid_context)
      return my_widths if my_widths.sum <= grid_context.width

      difference = my_widths.sum - grid_context.width
      col_to_reduce = (my_widths.reverse.find_index { |width| !width.zero? } * -1) - 1
      my_widths[col_to_reduce] = [0, my_widths[col_to_reduce] - difference].max
      recursively_reduce_final_column(my_widths, grid_context)
    end
  end
end
