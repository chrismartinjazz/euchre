# frozen_string_literal: true

# A playing card. Expects a suit in format "C/D/H/S/J" where J is Joker.
class Card
  SUITS = { C: '♣', D: '♦', H: '♥', S: '♠', J: 'J' }.freeze

  def initialize(rank, suit)
    @rank = rank
    @suit = suit.to_sym
  end

  def to_s
    suit = @suit == :D || @suit == :H ? "\e[31m#{SUITS[@suit]}\e[0m" : SUITS[@suit]
    "#{@rank}#{suit}"
  end
end
