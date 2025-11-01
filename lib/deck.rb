# frozen_string_literal: true

# A deck of cards.
class Deck
  attr_reader :cards

  def initialize(ranks: %w[2 3 4 5 6 7 8 9 T J Q K A], suits: %w[C D H S], joker_count: 2)
    @ranks = ranks
    @suits = suits
    @joker_count = joker_count
    @joker_rank = '?'
    @joker_suit = 'J'
    @cards = create_cards
  end

  def shuffle
    @cards.shuffle!
  end

  def deal(count)
    @cards.shift(count) if @cards.length >= count
  end

  private

  def create_cards
    cards = []
    @ranks.each do |rank|
      @suits.each do |suit|
        cards.push(Card.new(rank, suit))
      end
    end
    @joker_count.times do
      cards.push(Card.new(@joker_rank, @joker_suit))
    end
    cards
  end
end
