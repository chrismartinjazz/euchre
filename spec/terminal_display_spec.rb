# frozen_string_literal: true

require 'euchre'
require 'helpers'

module Euchre
  include Euchre::Constants
  RSpec.describe TerminalDisplay::Display do
    let(:display) { TerminalDisplay::Display.new }

    let(:north) { Players::ComputerPlayer.new(name: "North") }
    let(:east) { Players::ComputerPlayer.new(name: "East") }
    let(:south) { Players::HumanPlayer.new(name: "South") }
    let(:west) { Players::ComputerPlayer.new(name: "West") }
    let(:players) { GameState::Players.new(
      south: south,
      west: west,
      north: north,
      east: east
    ) }
    let(:bid) { GameState::Bid.new(
      pass: false,
      trumps: CLUBS,
      going_alone: false,
      bidder: south,
      bidders: [south, north],
      defenders: [west, east]
    ) }
    let(:tricks) { Array.new(5) { Props::Trick.new(trumps: CLUBS) } }
    let(:context) { GameState::Context.new(
      players: players,
      display_order: [south, west, north, east],
      player_order: [south, west, north, east],
      dealer: north,
      center_card: nil,
      center_card_suit: nil,
      bid: bid,
      tricks: tricks
    )}

    let(:deck) { Props::Deck.new(ranks: RANKS[:non_trumps], joker_count: 1) }

    before do
      players.team1 = [south, north]
      players.team2 = [west, east]
      context.score = { players.team1 => 6, players.team2 => 7 }
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
      context.center_card = Props::Card.for(rank: JOKER, suit: JOKER_SUIT)
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
      context.tricks[0].add(player: south, card: Props::Card.for(rank: TEN, suit: DIAMONDS))
      context.tricks[0].add(player: west, card: Props::Card.for(rank: JACK, suit: CLUBS))
      context.tricks[0].add(player: north, card: Props::Card.for(rank: ACE, suit: DIAMONDS))
      context.tricks[0].add(player: east, card: Props::Card.for(rank: JACK, suit: SPADES))
      context.tricks[1].add(player: east, card: Props::Card.for(rank: ACE, suit: SPADES))
      context.tricks[1].add(player: south, card: Props::Card.for(rank: JOKER, suit: JOKER_SUIT))
      silence do
        puts
        result = display.tricks(context: context)
        expect(result).to eq nil
      end
    end
  end
end
