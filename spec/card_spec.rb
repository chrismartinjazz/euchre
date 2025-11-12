# frozen_string_literal: true

require 'card'

RSpec.describe Card do
  it 'creates card with expected rank and suit from string' do
    card = Card.new('T', 'D')
    expect(card.rank).to eq :T
    expect(card.suit).to eq :D
  end

  it 'creates card with expected rank and suit from symbol' do
    card = Card.new(:T, :D)
    expect(card.rank).to eq :T
    expect(card.suit).to eq :D
  end

  it 'gives a string representation of the card in expected format' do
    ten_of_diamonds = Card.new(:T, :D)
    expect(ten_of_diamonds.to_s).to eq "T\e[31m♦\e[0m"

    queen_of_hearts = Card.new(:Q, :H)
    expect(queen_of_hearts.to_s).to eq "Q\e[31m♥\e[0m"

    jack_of_spades = Card.new(:J, :S)
    expect(jack_of_spades.to_s).to eq 'J♠'

    five_of_clubs = Card.new(:'5', :C)
    expect(five_of_clubs.to_s).to eq '5♣'

    joker = Card.new(:'?', :J)
    expect(joker.to_s).to eq '?J'
  end

  it 'reports its own suit, based on which suit is trumps, following the rules of euchre' do
    joker = Card.new(:'?', :J)
    expect(joker.suit).to eq :J
    expect(joker.suit(:D)).to eq :D

    jack_of_diamonds = Card.new(:J, :D)
    expect(jack_of_diamonds.suit).to eq :D
    expect(jack_of_diamonds.suit(:D)).to eq :D
    expect(jack_of_diamonds.suit(:H)).to eq :H
  end
end
