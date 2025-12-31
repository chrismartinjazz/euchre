# frozen_string_literal: true

module Euchre
  module TerminalGrid
    # A cell in a grid. Cell.contents is an array where each elements represents each line of text. Cell.justified takes
    # values :left, :center or :right and will apply to all lines of text. Cell.width represents a 'set' width.
    class Cell
      attr_reader :contents, :justified, :width

      def initialize(contents:, justified: :left, width: :flex)
        @contents = validate_contents(contents)
        @justified = validate_justified(justified)
        @width = validate_width(width)
      end

      def update(contents: @contents, justified: @justified, width: @width)
        @contents = validate_contents(contents) unless @contents == contents
        @justified = validate_justified(justified) unless @justified == justified
        @width = validate_width(width) unless @width == width
        self
      end

      private

      def validate_contents(contents)
        return contents.map(&:to_s) if contents.is_a?(Array)

        [contents.to_s].dup.freeze
      end

      def validate_justified(justified)
        return justified if %i[left center right].include?(justified)

        raise ArgumentError('Cell.justified may take values :left, :center, :right')
      end

      def validate_width(width)
        return width if width == :flex || (width.is_a?(Integer) && width.positive?)

        raise ArgumentError('Cell.width must be either :flex or a positive integer')
      end
    end
  end
end
