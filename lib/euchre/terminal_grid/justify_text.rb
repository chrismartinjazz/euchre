# frozen_string_literal: true

module Euchre
  module TerminalGrid
    # Handles left, center, right justification of text in a cell.
    class JustifyText
      def justify(text:, justified:, width:, border:)
        text = text.to_s
        col_width = compensate_width_for_ansi_escape(text, width) - border.vertical.length
        border ||= Border.new(vertical: '|', horizontal: '-', corner: '+')

        case justified
        when :center
          center_justify(text, col_width, border)
        when :right
          right_justify(text, col_width, border)
        else
          left_justify(text, col_width, border)
        end
      end

      def compensate_width_for_ansi_escape(text, width)
        width + text.scan(ANSI_ESCAPE).join.length
      end

      def center_justify(text, col_width, border)
        space_before = ' ' * [((-0.5 * text.length) + (col_width / 2.0)).floor, 0].max
        space_after = ' ' * [((-0.5 * text.length) + (col_width / 2.0)).ceil, 0].max
        safe_join([space_before, text, space_after, border.vertical], col_width, border)
      end

      def right_justify(text, col_width, border)
        space_before = ' ' * [(col_width - text.length), 0].max
        safe_join([space_before, text, border.vertical], col_width, border)
      end

      def left_justify(text, col_width, border)
        space_after = ' ' * [(col_width - text.length), 0].max
        safe_join([text, space_after, border.vertical], col_width, border)
      end

      def safe_join(array, col_width, border)
        array.join[0..[(col_width + border.vertical.length), 0].max]
      end
    end
  end
end
