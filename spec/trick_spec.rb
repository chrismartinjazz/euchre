# frozen_string_literal: true

require 'constants'
require 'trick'
require 'card'
require 'player'

RSpec.describe Trick do
  context 'with four players, south, west, north and east' do
    south = Player.new(name: "South")
    west = Player.new(name: "West")
    north = Player.new(name: "North")
    east = Player.new(name: "East")

    it 'adds a card to a trick successfully' do
      trick = Trick.new(trumps: CLUBS)
      ten_of_diamonds = Card.new(rank: TEN, suit: DIAMONDS)
      trick.add(player: south, card: ten_of_diamonds)
      expect(trick.plays[0][:player]).to eq south
      expect(trick.plays[0][:card]).to eq ten_of_diamonds
    end

    it 'identifies winning plays in the lead suit, with other non-trump cards' do
      ten_of_diamonds = Card.new(rank: TEN, suit: DIAMONDS)
      king_of_diamonds = Card.new(rank: KING, suit: DIAMONDS)
      nine_of_diamonds = Card.new(rank: NINE, suit: DIAMONDS)
      ace_of_spades = Card.new(rank: ACE, suit: SPADES)
      trumps = CLUBS

      trick = Trick.new(trumps: trumps)
      trick.add(player: south, card: ten_of_diamonds)
      expect(trick.winning_play[:card]).to eq ten_of_diamonds
      trick.add(player: west, card: king_of_diamonds)
      expect(trick.winning_play[:card]).to eq king_of_diamonds
      trick.add(player: north, card: nine_of_diamonds)
      expect(trick.winning_play[:card]).to eq king_of_diamonds
      expect(trick.winner).to eq nil

      trick.add(player: north, card: ace_of_spades)
      expect(trick.winning_play[:card]).to eq king_of_diamonds
      expect(trick.winner).to eq west
    end
    it 'identifies winning plays considering the suit that is lead, and trumping the leader' do
      ten_of_diamonds = Card.new(rank: TEN, suit: DIAMONDS)
      ace_of_spades = Card.new(rank: ACE, suit: SPADES)
      nine_of_diamonds = Card.new(rank: NINE, suit: DIAMONDS)
      nine_of_clubs = Card.new(rank: NINE, suit: CLUBS)
      trumps = CLUBS

      trick = Trick.new(trumps: trumps)
      trick.add(player: south, card: ten_of_diamonds)
      expect(trick.winning_play[:card]).to eq ten_of_diamonds
      trick.add(player: west, card: ace_of_spades)
      expect(trick.winning_play[:card]).to eq ten_of_diamonds
      trick.add(player: north, card: nine_of_diamonds)
      expect(trick.winning_play[:card]).to eq ten_of_diamonds
      trick.add(player: north, card: nine_of_clubs)
      expect(trick.winning_play[:card]).to eq nine_of_clubs
      expect(trick.winner).to eq north
    end

    it 'identifies winning plays in tricks including the joker and bowers' do
      joker = Card.new(rank: JOKER, suit: JOKER_SUIT)
      jack_of_clubs = Card.new(rank: JACK, suit: CLUBS)
      jack_of_spades = Card.new(rank: JACK, suit: SPADES)
      ace_of_clubs = Card.new(rank: ACE, suit: CLUBS)
      trumps = CLUBS

      trick = Trick.new(trumps: trumps)
      trick.add(player: east, card: ace_of_clubs)
      expect(trick.winning_play[:card]).to eq ace_of_clubs
      trick.add(player: south, card: jack_of_spades)
      expect(trick.winning_play[:card]).to eq jack_of_spades
      trick.add(player: west, card: jack_of_clubs)
      expect(trick.winning_play[:card]).to eq jack_of_clubs
      trick.add(player: north, card: joker)
      expect(trick.winning_play[:card]).to eq joker
      expect(trick.winner).to eq north
    end

    it 'reports the card played by a given player in a trick' do
      joker = Card.new(rank: JOKER, suit: JOKER_SUIT)
      jack_of_clubs = Card.new(rank: JACK, suit: CLUBS)
      jack_of_spades = Card.new(rank: JACK, suit: SPADES)
      ace_of_clubs = Card.new(rank: :A, suit: CLUBS)
      trumps = :C

      trick = Trick.new(trumps: trumps)
      expect(trick.card(player: east)).to eq nil

      trick.add(player: east, card: ace_of_clubs)
      trick.add(player: south, card: jack_of_spades)
      trick.add(player: west, card: jack_of_clubs)
      trick.add(player: north, card: joker)
      expect(trick.card(player: east)).to eq ace_of_clubs
      expect(trick.card(player: south)).to eq jack_of_spades
    end
  end
end
