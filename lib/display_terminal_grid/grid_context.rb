# frozen_string_literal: true

module DisplayTerminalGrid
  GridContext = Struct.new(
    :grid,
    :width,
    :border,
    :row_heights,
    :col_widths
  )
end
