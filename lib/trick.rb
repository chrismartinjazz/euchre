# frozen_string_literal: true

require_relative 'ranks'

# A Trick.
class Trick
  attr_reader :plays, :lead_suit

  def initialize(trumps)
    @trumps = trumps
    @lead_suit = nil
    @plays = []
  end

  def add(player, card)
    @lead_suit = card.suit if @lead_suit.nil?
    @plays.push({ player: player, card: card, rating: evaluate_card(card) })
  end

  def winning_play
    @plays.length >= 4 ? @plays.max_by { |play| play[:rating] } : nil
  end

  def winner
    winning_play[:player] || nil
  end

  def card(player)
    @plays.find { |play| play[:player] == player }
  end

  private

  def evaluate_card(card)
    return 0 if card.suit(@trumps) != @trumps && card.suit(@trumps) != @lead_suit

    rank = card.rank
    rank = :left_bower if rank == :J && card.suit != card.suit(@trumps)
    card.suit(@trumps) == @trumps ? 100 + RANKS[:trumps].find_index(rank) : RANKS[:non_trumps].find_index(rank)
  end
end
