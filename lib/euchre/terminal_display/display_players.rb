# frozen_string_literal: true

require_relative '../constants'
require_relative '../terminal_grid'

module Euchre
  module TerminalDisplay
    # Displays bidding screen
    class DisplayPlayers
      include Euchre::Constants
      include TerminalGrid

      def grid(context:)
        south, west, north, east = generate_player_cells(context)
        center = generate_center_cell(context)
        blank = Cell.new(contents: [], justified: :left)
        player_grid = Grid.new(
          grid: [
            [blank, north, blank],
            [west, center, east],
            [blank, south, blank]
          ],
          border: Border.new(vertical: '', horizontal: ' ', corner: '')
        )
        puts player_grid
      end

      private

      def generate_player_cells(context)
        south, west, north, east = context.display_order.each_with_object([]) do |player, array|
          array.push(Cell.new(contents: [player_name(player, context), hand_text(player)]))
        end
        south.update(justified: :center)
        west.update(justified: :left)
        north.update(justified: :center)
        east.update(justified: :right)
        [south, west, north, east]
      end

      def generate_center_cell(context)
        center_suit_text = context.center_card.rank == JOKER ? "#{SUITS[context.center_card_suit][:glyph]} |" : '|'
        center_text = "| #{context.center_card} #{center_suit_text}"
        center_box = "+#{'-' * [(clean(center_text).length - 2), 0].max}+"
        Cell.new(contents: [center_box, center_text, center_box], justified: :center)
      end

      def player_name(player, context)
        player == context.dealer ? "#{player.to_s.upcase} *DEALER*" : player.to_s
      end

      def hand_text(player, separator = ' |', card_back = ' %')
        hand = player.is_a?(Players::HumanPlayer) ? player.hand : Array.new(player.hand.length) { card_back }
        hand.join(separator)
      end

      def clean(text)
        text.to_s.gsub(ANSI_ESCAPE, '')
      end
    end
  end
end
