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
    return nil if complete? || !card(player: player).nil?

    @lead_suit = card.suit(trumps: @trumps) if @lead_suit.nil?
    @plays.push({ player: player, card: card, rating: evaluate_card(card) })[0]
  end

  def winner
    complete? ? winning_play[:player] : nil
  end

  def complete?
    @plays.length == @player_count
  end

  def winning_play
    @plays.max_by { |play| play[:rating] } || { player: nil, card: nil, rating: nil }
  end

  def card(player:)
    player_card = @plays.find { |play| play[:player] == player } || {}
    player_card[:card]
  end

  private

  def evaluate_card(card)
    suit = card.suit(trumps: @trumps)
    rank = card.rank(trumps: @trumps)

    # If a card is not trumps and has not followed suit, it cannot win the trick.
    return 0 if suit != @trumps && suit != @lead_suit

    suit == @trumps ? 100 + RANKS[:trumps].find_index(rank) : RANKS[:non_trumps].find_index(rank)
  end
end
