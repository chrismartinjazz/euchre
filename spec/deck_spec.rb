# frozen_string_literal: true

require 'deck'

RSpec.describe Deck do
  it 'creates a standard 52-card deck' do
    deck = Deck.new()
    expect(deck.cards.length).to eq 52
  end
end

RSpec.describe Deck do
  it 'shuffles the deck' do
    deck = Deck.new()
    initial_cards = deck.cards.dup
    deck.shuffle
    shuffled_cards = deck.cards
    expect(initial_cards != shuffled_cards).to be true
  end
end

RSpec.describe Deck, "#deal" do
  it 'deals cards into an array of cards, removing them from the deck' do
    deck = Deck.new()
    hand = deck.deal(count: 5)
    expect(hand.instance_of?(Array)).to be true
    expect(hand.length).to eq 5
    expect(deck.cards.length).to eq 47
  end
end

RSpec.describe Deck, "#draw_one" do
  it 'deals a single card as a Card object' do
    deck = Deck.new()
    card = deck.draw_one
    expect(card.instance_of?(Card)).to be true
    expect(deck.cards.length).to eq 51
  end
end
