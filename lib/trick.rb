# frozen_string_literal: true

require_relative 'constants'

# A Trick.
class Trick
  attr_reader :plays, :lead_suit

  def initialize(trumps:, player_count: 4)
    @trumps = trumps
    @lead_suit = nil
    @plays = []
    @player_count = player_count
  end

  def add(player:, card:)
    @lead_suit = card.suit(trumps: @trumps) if @lead_suit.nil?
    @plays.push({ player: player, card: card, rating: evaluate_card(card) })
  end

  def winner
    trick_complete? ? winning_play[:player] : nil
  end

  def trick_complete?
    @plays.length == @player_count
  end

  def winning_play
    @plays.max_by { |play| play[:rating] }
  end

  def card(player:)
    player_card = @plays.find { |play| play[:player] == player } || {}
    player_card[:card]
  end

  private

  def evaluate_card(card)
    suit = card.suit(trumps: @trumps)
    rank = left_bower?(card) ? LEFT_BOWER_RANK : card.rank

    # If a card is not trumps and has not followed suit, it cannot win the trick.
    return 0 if suit != @trumps && suit != @lead_suit

    suit == @trumps ? 100 + RANKS[:trumps].find_index(rank) : RANKS[:non_trumps].find_index(rank)
  end

  def left_bower?(card)
    card.rank == BOWER_RANK && card.suit != card.suit(trumps: @trumps)
  end
end
