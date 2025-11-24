# frozen_string_literal: true

require 'trick'
require 'card'
require 'player'

# trick.add(player: card, player)
# trick.winner
# trick.rate_card

RSpec.describe Trick do
  context 'with four players, south, west, north and east' do
    south = Player.new(name: "South")
    west = Player.new(name: "West")
    north = Player.new(name: "North")
    east = Player.new(name: "East")

    it 'identifies winning plays in the lead suit, with other non-trump cards' do
      ten_of_diamonds = Card.new(:T, :D)
      king_of_diamonds = Card.new(:K, :D)
      nine_of_diamonds = Card.new(:'9', :D)
      ace_of_spades = Card.new(:A, :S)
      trumps = :C

      trick = Trick.new(trumps)
      trick.add(south, ten_of_diamonds)
      expect(trick.winning_play[:card]).to have_attributes(rank: :T, suit: :D)
      trick.add(west, king_of_diamonds)
      expect(trick.winning_play[:card]).to have_attributes(rank: :K, suit: :D)
      trick.add(north, nine_of_diamonds)
      expect(trick.winning_play[:card]).to have_attributes(rank: :K, suit: :D)
      trick.add(north, ace_of_spades)
      expect(trick.winning_play[:card]).to have_attributes(rank: :K, suit: :D)
    end
    it 'identifies winning plays considering the suit that is lead, and trumping the leader' do
      ten_of_diamonds = Card.new(:T, :D)
      ace_of_spades = Card.new(:A, :S)
      nine_of_diamonds = Card.new(:'9', :D)
      nine_of_clubs = Card.new(:'9', :C)
      trumps = :C

      trick = Trick.new(trumps)
      trick.add(south, ten_of_diamonds)
      expect(trick.winning_play[:card]).to have_attributes(rank: :T, suit: :D)
      trick.add(west, ace_of_spades)
      expect(trick.winning_play[:card]).to have_attributes(rank: :T, suit: :D)
      trick.add(north, nine_of_diamonds)
      expect(trick.winning_play[:card]).to have_attributes(rank: :T, suit: :D)
      trick.add(north, nine_of_clubs)
      expect(trick.winning_play[:card]).to have_attributes(rank: :'9', suit: :C)
    end

    it 'identifies winning plays in tricks including the joker and bowers' do
      joker = Card.new(:'?', :J)
      jack_of_clubs = Card.new(:J, :C)
      jack_of_spades = Card.new(:J, :S)
      ace_of_clubs = Card.new(:A, :C)
      trumps = :C

      trick = Trick.new(trumps)
      trick.add(east, ace_of_clubs)
      expect(trick.winning_play[:card]).to have_attributes(rank: :A, suit: :C)
      trick.add(south, jack_of_spades)
      expect(trick.winning_play[:card]).to have_attributes(rank: :J, suit: :S)
      trick.add(west, jack_of_clubs)
      expect(trick.winning_play[:card]).to have_attributes(rank: :J, suit: :C)
      trick.add(north, joker)
      expect(trick.winning_play[:card]).to have_attributes(rank: :'?', suit: :J)
    end
  end
end

    # Clubs are trumps.
    # Tricks are:
    # South: TD West: AD North: 9D East: 9C (9C East)
    # East: ?J South: TC West: JC North: QC (?J East)
    # East: AC South: KC West: JS North: 9S (JS West)
    # West: JH North: QH East: AH South: TS (AH East)
    # East: KH South: KS, West: TH, North: QS (KH East)
