# frozen_string_literal: true

require_relative 'constants'
require_relative 'modules/human_player_helpers'

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
    valid_hand_indices = []
    if can_follow_suit
      hand.each_with_index { |card, index| valid_hand_indices.push(index) if card.suit(trumps: trumps) == lead_suit }
    else
      valid_hand_indices = [*0..(hand.length - 1)]
    end
    valid_hand_indices.map { |card| (card + 1).to_s }
  end
end
