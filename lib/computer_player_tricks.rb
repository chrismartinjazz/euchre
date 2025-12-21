# frozen_string_literal: true

require_relative 'constants'
require_relative 'modules/computer_player_helpers'

# Manages the playing of cards during tricks for ComputerPlayer
class ComputerPlayerTricks
  include ComputerPlayerHelpers

  attr_writer :name

  def initialize
    @name = 'Unknown'
  end

  def play_card(trumps:, tricks:, trick_index:, hand:)
    @hand = hand
    valid_hand_indices = find_valid_hand_indices(trumps, tricks, trick_index)
    index = choose_card(valid_hand_indices, trumps, tricks[trick_index])
    announce(@name, @hand[index].to_s, confirmation: true)
    @hand.delete_at(index)
  end

  private

  def choose_card(valid_hand_indices, trumps, trick)
    scores = {}
    valid_hand_indices.each { |index| scores[index] = evaluate_card(@hand[index], trumps) }
    # If the strongest card in my hand can't win the trick, play the weakest available card.
    # If my partner is already winning the trick with a trump Ace or higher, play weakest available.
    index_of_my_strongest_card = scores.max_by { |_k, v| v }[0]
    index_of_my_weakest_card = scores.min_by { |_k, v| v }[0]
    current_winning_card = trick.winning_play ? trick.winning_play[:card] : nil
    i_can_win_trick = evaluate_card(current_winning_card, trumps) < scores[index_of_my_strongest_card]

    if DISPLAY_THINKING
      announce(
        @name,
        "scores: #{scores}, strongest: #{index_of_my_strongest_card}, weakest: #{index_of_my_weakest_card}" \
        "current winning card: #{current_winning_card}, i can win trick: #{i_can_win_trick}"
      )
    end
    i_can_win_trick ? index_of_my_strongest_card : index_of_my_weakest_card
  end

  def find_valid_hand_indices(trumps, tricks, trick_index)
    lead_suit = tricks[trick_index].lead_suit
    can_follow_suit = @hand.any? { |card| card.suit(trumps: trumps) == lead_suit }
    valid_hand_indices = []
    if can_follow_suit
      @hand.each_with_index { |card, index| valid_hand_indices.push(index) if card.suit(trumps: trumps) == lead_suit }
    else
      valid_hand_indices = [*0..(@hand.length - 1)]
    end
    valid_hand_indices
  end

  def score_hand(trumps, hand = @hand)
    hand.map { |card| evaluate_card(card, trumps) }.sum / hand.size.to_f
  end

  def evaluate_card(card, trumps)
    return 0 if card.nil?

    suit = card.suit(trumps: trumps)
    rank = card.rank(trumps: trumps)

    suit == trumps ? 6 + RANKS[:trumps].find_index(rank) : RANKS[:non_trumps].find_index(rank)
  end
end
