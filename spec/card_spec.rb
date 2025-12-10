# frozen_string_literal: true

require 'card'
require 'constants'

RSpec.describe Card do
  it 'creates card with expected rank and suit' do
    card = Card.new(rank: TEN, suit: DIAMONDS)
    expect(card.rank).to eq TEN
    expect(card.suit).to eq DIAMONDS
  end

  it 'gives a string representation of the card in expected format' do
    ten_of_diamonds = Card.new(rank: TEN, suit: DIAMONDS)
    expect(ten_of_diamonds.to_s).to eq "T\e[31m♦\e[0m"

    queen_of_hearts = Card.new(rank: QUEEN, suit: HEARTS)
    expect(queen_of_hearts.to_s).to eq "Q\e[31m♥\e[0m"

    jack_of_spades = Card.new(rank: JACK, suit: SPADES)
    expect(jack_of_spades.to_s).to eq 'J♠'

    ace_of_clubs = Card.new(rank: ACE, suit: CLUBS)
    expect(ace_of_clubs.to_s).to eq 'A♣'

    joker = Card.new(rank: JOKER, suit: JOKER_SUIT)
    expect(joker.to_s).to eq '?J'
  end

  it 'reports its own suit, based on which suit is trumps, following the rules of euchre' do
    joker = Card.new(rank: JOKER, suit: JOKER_SUIT)
    expect(joker.suit).to eq JOKER_SUIT
    expect(joker.suit(trumps: DIAMONDS)).to eq DIAMONDS

    jack_of_diamonds = Card.new(rank: JACK, suit: DIAMONDS)
    expect(jack_of_diamonds.suit).to eq DIAMONDS
    expect(jack_of_diamonds.suit(trumps: DIAMONDS)).to eq DIAMONDS
    expect(jack_of_diamonds.suit(trumps: HEARTS)).to eq HEARTS
  end
end
