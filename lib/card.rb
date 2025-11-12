# frozen_string_literal: true

require_relative 'suits'

# A playing card. Expects a suit in format "C/D/H/S/J" where J is Joker.
class Card
  attr_reader :rank

  def initialize(rank, suit)
    @rank = rank.to_s.upcase.to_sym
    @suit = suit.to_s.upcase.to_sym
  end

  def suit(trumps = nil)
    # If no suit is specified, return the card's native suit
    return @suit if trumps.nil?

    # If the card is a joker, return the trumps suit (nil if not supplied)
    return trumps if @suit == :J

    # If the card is a Jack, handle left and right bower
    if @rank == :J
      return trumps if red_suit?(trumps) && red_suit?(@suit)

      return trumps if black_suit?(trumps) && black_suit?(@suit)
    end

    @suit
  end

  def to_s
    glyph = SUITS[@suit][:glyph]
    suit = red_suit?(@suit) ? red(glyph) : glyph
    "#{@rank}#{suit}"
  end

  private

  def red_suit?(suit)
    suit == :D || suit == :H
  end

  def black_suit?(suit)
    suit == :C || suit == :S
  end

  def red(text)
    "\e[31m#{text}\e[0m"
  end
end
