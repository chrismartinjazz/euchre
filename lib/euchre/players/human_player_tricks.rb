# frozen_string_literal: true

require_relative '../constants'
require_relative 'human_player_helpers'

module Euchre
  module Players
    # Manages the playing of cards during tricks for HumanPlayer
    class HumanPlayerTricks
      include HumanPlayerHelpers

      attr_writer :name

      def initialize
        @name = 'Unknown'
      end

      def play_card(trumps:, tricks:, trick_index:, hand:)
        valid_card_numbers = find_valid_card_numbers(trumps, tricks, trick_index, hand)
        prompt = "Choose a card to play (1-#{hand.length}):\n#{hand_text(hand, trumps)}"
        chosen_card_number = get_player_input(@name, prompt, valid_card_numbers).to_i
        hand.delete_at(chosen_card_number - 1)
      end

      private

      def find_valid_card_numbers(trumps, tricks, trick_index, hand)
        lead_suit = tricks[trick_index].lead_suit
        can_follow_suit = hand.any? { |card| card.suit(trumps: trumps) == lead_suit }
        valid_hand_indices = if can_follow_suit
                               card_indices_that_follow_suit(hand, lead_suit, trumps)
                             else
                               all_card_indices(hand)
                             end
        valid_hand_indices.map { |card| (card + 1).to_s }
      end

      def card_indices_that_follow_suit(hand, lead_suit, trumps)
        hand.map.with_index { |card, index| card.suit(trumps: trumps) == lead_suit ? index : nil }.compact
      end

      def all_card_indices(hand)
        [*0..(hand.length - 1)]
      end
    end
  end
end
