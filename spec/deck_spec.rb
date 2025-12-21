# frozen_string_literal: true

require 'deck'

RSpec.describe Deck do
  context 'with a standard 52-card deck' do
    let(:deck) { Deck.new }

    it 'creates a standard 52-card deck' do
      expect(deck.cards.length).to eq 52
    end

    it 'shuffles the deck' do
      initial_cards = deck.cards.dup
      deck.shuffle until deck.cards != initial_cards

      expect(deck.cards).to match_array(initial_cards)
    end

    it 'deals cards into an array of cards, removing them from the deck' do
      hand = deck.deal(count: 5)

      expect(hand).to be_kind_of(Array)
      expect(hand.length).to eq 5
      expect(deck.cards.length).to eq 47
      expect(deck.cards).not_to include(*hand)
    end

    it 'draws a single card, removing it from the deck' do
      card = deck.draw_one
      expect(card).to have_attributes(rank: anything, suit: anything)
      expect(deck.cards.length).to eq 51
      expect(deck.cards).not_to include(card)
    end
  end

  context 'with a euchre deck' do
    let(:deck) { Deck.new(ranks: [:'9', :T, :J, :K, :Q, :A], joker_count: 1) }

    it 'creates a deck of the correct size (9-A in each suit is 6, times 4 suits, plus 1 Joker is 25 cards)' do
      expect(deck.cards.size).to eq 25
    end
  end
end
