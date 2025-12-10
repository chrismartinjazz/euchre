# frozen_string_literal: true

require_relative 'constants'

# A playing card. Reports its rank and suit, based on the trump suit, accounting for joker and bowers.
class Card
  def initialize(rank:, suit:)
    @rank = rank.to_s.upcase.to_sym
    @suit = suit.to_s.upcase.to_sym
  end

  def rank(trumps: nil)
    return @rank if trumps.nil?

    left_bower?(trumps) ? LEFT_BOWER : @rank
  end

  def suit(trumps: nil)
    return @suit if trumps.nil?

    left_bower?(trumps) || joker? ? trumps : @suit
  end

  def to_s(trumps: nil)
    glyph = SUITS[@suit][:glyph]
    "#{rank(trumps: trumps)}#{glyph}"
  end

  private

  def left_bower?(trumps)
    @rank == JACK && @suit != trumps && SUITS[@suit][:color] == SUITS[trumps][:color]
  end

  def joker?
    @suit == JOKER_SUIT
  end
end
