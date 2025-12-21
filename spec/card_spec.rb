# frozen_string_literal: true

require 'card'
require 'constants'

RSpec.describe Card do
  let(:ten_of_diamonds) { Card.new(rank: TEN, suit: DIAMONDS) }
  let(:queen_of_hearts) { Card.new(rank: QUEEN, suit: HEARTS) }
  let(:jack_of_spades) { Card.new(rank: JACK, suit: SPADES) }
  let(:ace_of_clubs) { Card.new(rank: ACE, suit: CLUBS) }
  let(:joker) { Card.new(rank: JOKER, suit: JOKER_SUIT) }

  it 'creates card with expected rank and suit' do
    expect(ten_of_diamonds.rank).to eq TEN
    expect(ten_of_diamonds.suit).to eq DIAMONDS
  end

  it 'gives a string representation of cards in expected format' do
    expect(ten_of_diamonds.to_s).to eq "T\e[31m♦\e[0m"
    expect(queen_of_hearts.to_s).to eq "Q\e[31m♥\e[0m"
    expect(jack_of_spades.to_s).to eq 'J♠'
    expect(ace_of_clubs.to_s).to eq 'A♣'
    expect(joker.to_s).to eq '?J'
  end

  context 'jack of spades' do
    it 'correctly reports its rank, with respect to the trump suit, handling left bower' do
      expect(jack_of_spades.rank(trumps: SPADES)).to eq JACK
      expect(jack_of_spades.rank(trumps: CLUBS)).to eq LEFT_BOWER
      expect(jack_of_spades.rank(trumps: HEARTS)).to eq JACK
    end

    it 'correctly reports its suit, with respect to the trump suit, handling left bower' do
      expect(jack_of_spades.suit(trumps: SPADES)).to eq SPADES
      expect(jack_of_spades.suit(trumps: CLUBS)).to eq CLUBS
      expect(jack_of_spades.suit(trumps: HEARTS)).to eq SPADES
    end
  end

  context 'joker' do
    it 'correctly reports its suit with respect to the trump suit (i.e., it is always trumps)' do
      expect(joker.suit).to eq JOKER_SUIT
      expect(joker.suit(trumps: DIAMONDS)).to eq DIAMONDS
    end
  end
end
