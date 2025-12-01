# frozen_string_literal: true

require_relative 'ranks'

# A Trick.
class Trick
  attr_reader :plays, :lead_suit

  def initialize(trumps, player_count = 4)
    @trumps = trumps
    @lead_suit = nil
    @plays = []
    @player_count = player_count
  end

  def add(player, card)
    @lead_suit = card.suit(@trumps) if @lead_suit.nil?
    @plays.push({ player: player, card: card, rating: evaluate_card(card) })
  end

  def winner
    trick_complete? ? winning_play[:player] : nil
  end

  def winning_play
    @plays.max_by { |play| play[:rating] }
  end

  def trick_complete?
    @plays.length == @player_count
  end

  def card(player)
    my_play = @plays.find { |play| play[:player] == player }
    return my_play[:card] if my_play

    nil
  end

  private

  def evaluate_card(card)
    return 0 if card.suit(@trumps) != @trumps && card.suit(@trumps) != @lead_suit

    rank = card.rank
    rank = :left_bower if rank == :J && card.suit != card.suit(@trumps)
    card.suit(@trumps) == @trumps ? 100 + RANKS[:trumps].find_index(rank) : RANKS[:non_trumps].find_index(rank)
  end
end
