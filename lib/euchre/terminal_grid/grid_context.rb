# frozen_string_literal: true

module Euchre
  module TerminalGrid
    GridContext = Struct.new(
      :grid,
      :width,
      :border,
      :row_heights,
      :col_widths
    )
  end
end
