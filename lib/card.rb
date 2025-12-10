# frozen_string_literal: true

require_relative 'constants'

# A playing card. Reports its rank and suit, based on the trump suit, accounting for joker and bowers.
class Card
  attr_reader :rank

  def initialize(rank:, suit:)
    @rank = rank.to_s.upcase.to_sym
    @suit = suit.to_s.upcase.to_sym
  end

  def suit(trumps: nil)
    return @suit if trumps.nil?

    bower?(trumps: trumps) || joker? ? trumps : @suit
  end

  def to_s
    glyph = SUITS[@suit][:glyph]
    "#{@rank}#{glyph}"
  end

  private

  def bower?(trumps:)
    @rank == BOWER_RANK && SUITS[@suit][:color] == SUITS[trumps][:color]
  end

  def joker?
    @suit == JOKER_SUIT
  end
end
