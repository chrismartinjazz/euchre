# frozen_string_literal: true

require 'card'
require 'constants'

RSpec.describe Card do
  it 'creates card with expected rank and suit from string' do
    card = Card.new(rank: 'T', suit: 'D')
    expect(card.rank).to eq :T
    expect(card.suit).to eq :D
  end

  it 'creates card with expected rank and suit from symbol' do
    card = Card.new(rank: :T, suit: :D)
    expect(card.rank).to eq :T
    expect(card.suit).to eq :D
  end

  it 'gives a string representation of the card in expected format' do
    ten_of_diamonds = Card.new(rank: :T, suit: :D)
    expect(ten_of_diamonds.to_s).to eq "T\e[31m♦\e[0m"

    queen_of_hearts = Card.new(rank: :Q, suit: :H)
    expect(queen_of_hearts.to_s).to eq "Q\e[31m♥\e[0m"

    jack_of_spades = Card.new(rank: :J, suit: :S)
    expect(jack_of_spades.to_s).to eq 'J♠'

    five_of_clubs = Card.new(rank: :'5', suit: :C)
    expect(five_of_clubs.to_s).to eq '5♣'

    joker = Card.new(rank: :'?', suit: :J)
    expect(joker.to_s).to eq '?J'
  end

  it 'reports its own suit, based on which suit is trumps, following the rules of euchre' do
    joker = Card.new(rank: :'?', suit: :J)
    expect(joker.suit).to eq :J
    expect(joker.suit(trumps: :D)).to eq :D

    jack_of_diamonds = Card.new(rank: :J, suit: :D)
    expect(jack_of_diamonds.suit).to eq :D
    expect(jack_of_diamonds.suit(trumps: :D)).to eq :D
    expect(jack_of_diamonds.suit(trumps: :H)).to eq :H
  end
end
