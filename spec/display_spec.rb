# frozen_string_literal: true

require 'constants'
require 'helpers'
require 'display'
require 'human_player'
require 'computer_player'
require 'card'
require 'deck'
require 'trick'

RSpec.describe Display do
  let(:north) { ComputerPlayer.new(name: "North") }
  let(:east) { ComputerPlayer.new(name: "East") }
  let(:south) { HumanPlayer.new(name: "South") }
  let(:west) { ComputerPlayer.new(name: "West") }
  let(:players) { [south, west, north, east] }
  let(:team1) { [north, south] }
  let(:team2) { [east, west] }
  let(:score) { {team1 => 6, team2 => 7} }
  let(:deck) { Deck.new(ranks: [NINE, TEN, JACK, QUEEN, KING, ACE], joker_count: 1) }
  let(:tricks) { Array.new(5) { Trick.new(trumps: CLUBS) } }

  let(:display) { Display.new }
  before do
    display.prepare(teams: [team1, team2], display_order: players, score: score)
    players.each { |player| player.add_to_hand(cards: deck.deal(count: 5)) }
  end

  it "displays the scoreboard as expected" do
    silence do
      result = display.score
      expect(result).to eq nil
    end
  end
  it "displays the bidding hands with north as dealer and a normal centre card" do
    centre_card = deck.draw_one
    silence do
      puts
      result = display.players(dealer: north, centre_card: centre_card, centre_card_suit: centre_card.suit)
      expect(result).to eq nil
    end
  end
  it "displays the bidding hands with east as dealer and a joker turned up as centre card" do
    centre_card = Card.for(rank: JOKER, suit: JOKER_SUIT)
    silence do
      puts
      result = display.players(dealer: east, centre_card: centre_card, centre_card_suit: DIAMONDS)
      expect(result).to eq nil
    end
  end
  it "displays an empty tricks table with clubs as trumps and indicates the bidding team" do
    silence do
      puts
      result = display.tricks(
        trumps: CLUBS,
        tricks: tricks,
        bidders: [north, south]
      )
      expect(result).to eq nil
    end
  end

  it "displays trick progress indicating the winning card in the round (to that point) and the trick winner, if there is one." do
    tricks = Array.new(5) { Trick.new(trumps: CLUBS) }
    tricks[0].add(player: south, card: Card.for(rank: TEN, suit: DIAMONDS))
    tricks[0].add(player: west, card: Card.for(rank: JACK, suit: CLUBS))
    tricks[0].add(player: north, card: Card.for(rank: ACE, suit: DIAMONDS))
    tricks[0].add(player: east, card: Card.for(rank: JACK, suit: SPADES))
    tricks[1].add(player: east, card: Card.for(rank: ACE, suit: SPADES))
    tricks[1].add(player: south, card: Card.for(rank: JOKER, suit: JOKER_SUIT))
    silence do
      puts
      result = display.tricks(
        trumps: CLUBS,
        tricks: tricks,
        bidders: [east, west]
      )
      expect(result).to eq nil
    end
  end
end
