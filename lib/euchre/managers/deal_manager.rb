# frozen_string_literal: true

require_relative '../constants'
require_relative '../props'

module Euchre
  module Managers
    # Manages the deck and dealing.
    class DealManager
      include Constants

      def prepare(context:)
        context.dealer ||= context.player_order.sample
        context
      end

      def deal(context:, display:, deck: nil)
        deck ||= Props::Deck.new(ranks: RANKS[:non_trumps], joker_count: 1)
        deck.shuffle
        context.player_order.each(&:reset_hand)
        context.player_order.each { |player| player.add_to_hand(cards: deck.deal(count: 5)) }
        context.center_card = deck.draw_one
        context.center_card_suit = handle_center_card(context, display)
        context
      end

      def rotate_player_order(context:, display:)
        # Find the dealer in the player order, and advance two positions around the table to find the new 'first player'.
        # Normalize the index (% 4), rotate the player order to start with this new player, set the dealer to be the last
        # player of the new player order.
        context.player_order.rotate!((context.player_order.find_index(context.dealer) + 2) % 4)
        context.dealer = context.player_order.last
        display.message(message: "New dealer is #{context.dealer}. Reshuffling . . . ", confirmation: true)
      end

      private

      def handle_center_card(context, display)
        if context.center_card.suit == JOKER_SUIT
          display.message(
            message: 'The turned up card is a joker! The dealer must choose a trump suit before looking at their hand.'
          )
          context.dealer.choose_a_suit
        else
          context.center_card.suit
        end
      end
    end
  end
end
