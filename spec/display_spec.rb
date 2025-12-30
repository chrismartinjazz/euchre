# frozen_string_literal: true

require 'display'
require 'context'
require 'players'
require 'bid'
require 'constants'
require 'helpers'
require 'human_player'
require 'computer_player'
require 'card'
require 'deck'
require 'trick'

RSpec.describe Display do
  let(:display) { Display.new }

  let(:north) { ComputerPlayer.new(name: "North") }
  let(:east) { ComputerPlayer.new(name: "East") }
  let(:south) { HumanPlayer.new(name: "South") }
  let(:west) { ComputerPlayer.new(name: "West") }
  let(:players) { Players.new(
    south: south,
    west: west,
    north: north,
    east: east
  ) }
  let(:bid) { Bid.new(
    pass: false,
    trumps: CLUBS,
    going_alone: false,
    bidder: south,
    bidders: [south, north],
    defenders: [west, east]
  ) }
  let(:tricks) { Array.new(5) { Trick.new(trumps: CLUBS) } }
  let(:context) { Context.new(
    players: players,
    display_order: [south, west, north, east],
    player_order: [south, west, north, east],
    dealer: north,
    center_card: nil,
    center_card_suit: nil,
    bid: bid,
    tricks: tricks
  )}

  let(:deck) { Deck.new(ranks: RANKS[:non_trumps], joker_count: 1) }

  before do
    players.team1 = [south, north]
    players.team2 = [west, east]
    context.score = { players.team1 => 6, players.team2 => 7 }
    display.prepare(context: context)
    context.display_order.each { |player| player.add_to_hand(cards: deck.deal(count: 5)) }
  end

  it "displays the scoreboard as expected" do
    silence do
      result = display.score(context: context)
      expect(result).to eq nil
    end
  end
  it "displays the bidding hands with north as dealer and a normal center card" do
    context.center_card = deck.draw_one
    context.center_card_suit = context.center_card.suit
    silence do
      puts
      result = display.players(context: context)
      expect(result).to eq nil
    end
  end
  it "displays the bidding hands with east as dealer and a joker turned up as center card" do
    context.center_card = Card.for(rank: JOKER, suit: JOKER_SUIT)
    context.center_card_suit = DIAMONDS
    silence do
      puts
      result = display.players(context: context)
      expect(result).to eq nil
    end
  end
  it "displays an empty tricks table with clubs as trumps and indicates the bidding team" do
    silence do
      puts
      result = display.tricks(context: context)
      expect(result).to eq nil
    end
  end

  it "displays trick progress indicating the winning card in the round (to that point) and the trick winner, if there is one." do
    context.tricks[0].add(player: south, card: Card.for(rank: TEN, suit: DIAMONDS))
    context.tricks[0].add(player: west, card: Card.for(rank: JACK, suit: CLUBS))
    context.tricks[0].add(player: north, card: Card.for(rank: ACE, suit: DIAMONDS))
    context.tricks[0].add(player: east, card: Card.for(rank: JACK, suit: SPADES))
    context.tricks[1].add(player: east, card: Card.for(rank: ACE, suit: SPADES))
    context.tricks[1].add(player: south, card: Card.for(rank: JOKER, suit: JOKER_SUIT))
    silence do
      puts
      result = display.tricks(context: context)
      expect(result).to eq nil
    end
  end
end
