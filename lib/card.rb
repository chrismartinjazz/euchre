# frozen_string_literal: true

require_relative './suits'

# A playing card. Expects a suit in format "C/D/H/S/J" where J is Joker.
class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit.to_s.upcase.to_sym
  end

  def to_s
    suit = @suit == :D || @suit == :H ? "\e[31m#{SUITS[@suit][:glyph]}\e[0m" : SUITS[@suit][:glyph]
    "#{@rank}#{suit}"
  end
end
