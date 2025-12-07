# frozen_string_literal: true

require_relative 'constants'
require_relative 'card'

# A deck of cards.
class Deck
  attr_reader :cards

  def initialize(ranks: %i[2 3 4 5 6 7 8 9 T J Q K A], suits: %i[C D H S], joker_count: 0)
    @ranks = ranks
    @suits = suits
    @joker_count = joker_count
    @cards = create_cards
  end

  def shuffle
    @cards.shuffle!
  end

  def deal(count)
    @cards.shift(count) if @cards.length >= count
  end

  def draw_one
    @cards.shift if @cards.length.positive?
  end

  private

  def create_cards
    cards = []
    @ranks.each do |rank|
      @suits.each do |suit|
        cards.push(Card.new(rank, suit))
      end
    end
    @joker_count.times { cards.push(Card.new(JOKER_RANK, JOKER_SUIT)) }
    cards
  end
end
