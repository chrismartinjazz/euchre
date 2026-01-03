# frozen_string_literal: true

require_relative '../constants'

module Euchre
  module TerminalDisplay
    # Handles displaying the tricks table
    class DisplayTricks
      include Euchre::Constants
      include TerminalGrid

      def grid(context:)
        grid = tricks_grid(context)
        puts grid
      end

      private

      def tricks_grid(context)
        grid = [grid_header(context)]
        0.upto(context.tricks.length - 1) { |trick_index| grid.push(grid_row(context, trick_index)) }
        Grid.new(grid: grid, width: 80, border: Border.new(vertical: '', horizontal: '', corner: ''))
      end

      def grid_header(context)
        header = [
          Cell.new(contents: ['Trumps:', SUITS[context.bid.trumps][:glyph].to_s], justified: :center, width: 7),
          Cell.new(contents: %w[Lead suit], justified: :center, width: 5)
        ]
        context.display_order.each do |player|
          name_text = context.bid.bidders.include?(player) ? "#{player.name}*" : player.name
          header.push(Cell.new(contents: [name_text], justified: :center))
        end
        header.push(Cell.new(contents: ['Winner'], justified: :center))
        header
      end

      def grid_row(context, trick_index)
        trick = context.tricks[trick_index]
        number = "#{trick_index + 1}:"
        lead_suit = trick.lead_suit.nil? ? ' ' : SUITS[trick.lead_suit][:glyph]
        winner = trick.winner ? trick.winner.to_s : ''

        row = [
          Cell.new(contents: [number], justified: :center, width: 7),
          Cell.new(contents: [lead_suit], justified: :center, width: 5)
        ]
        row.concat(grid_trick_cards(context, trick))
        row.push(Cell.new(contents: [winner], justified: :center))
      end

      def grid_trick_cards(context, trick)
        context.display_order.each.with_object([]) do |player, array|
          card = trick.card(player: player).nil? ? '' : trick.card(player:player).to_s(trumps: context.bid.trumps)
          winning = trick.winning_play[:card] && trick.winning_play[:card] == trick.card(player: player)
          array.push(Cell.new(contents: winning ? ["* #{card} *"] : [card], justified: :center))
        end
      end
    end
  end
end
