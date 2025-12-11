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
  context "with a set of four players" do
    north = ComputerPlayer.new(name: "North")
    east = ComputerPlayer.new(name: "East")
    south = HumanPlayer.new(name: "South")
    west = ComputerPlayer.new(name: "West")
    players = [north, east, south, west]
    deck = Deck.new(ranks: RANKS[:non_trumps], joker_count: 1)
    players.each { |player| player.add_to_hand(cards: deck.deal(count: 5)) }

    display = Display.new
    it "displays the scoreboard as expected" do
      teams = [[north, south], [east, west]]
      team1, team2 = teams
      score = {team1 => 6, team2 => 7}
      silence do
        result = display.score(teams: teams, score: score)
        expect(result).to eq nil
      end
    end

    it "displays the bidding hands with north as dealer and a normal centre card" do
      centre_card = deck.draw_one
      silence do
        puts
        result = display.bidding(players: players, dealer: north, centre_card: centre_card, centre_card_suit: centre_card.suit)
        expect(result).to eq nil
      end
    end

    it "displays the bidding hands with east as dealer and a joker turned up as centre card" do
      centre_card = Card.new(rank: JOKER, suit: JOKER_SUIT)
      # silence do
        puts
        result = display.bidding(players: players, dealer: east, centre_card: centre_card, centre_card_suit: DIAMONDS)
        expect(result).to eq nil
      # end
    end

    it "displays an empty tricks table with clubs as trumps and indicates the bidding team" do
      tricks = Array.new(5) { Trick.new(trumps: CLUBS) }
      silence do
        puts
        result = display.tricks(
          display_order: [south, west, north, east],
          trumps: CLUBS,
          tricks: tricks,
          bidding_team: [north, south]
        )
        expect(result).to eq nil
      end
    end

    it "displays trick progress indicating the winning card in the round (to that point) and the trick winner, if there is one." do
      tricks = Array.new(5) { Trick.new(trumps: CLUBS) }
      tricks[0].add(player: south, card: Card.new(rank: TEN, suit: DIAMONDS))
      tricks[0].add(player: west, card: Card.new(rank: JACK, suit: CLUBS))
      tricks[0].add(player: north, card: Card.new(rank: ACE, suit: DIAMONDS))
      tricks[0].add(player: east, card: Card.new(rank: JACK, suit: SPADES))
      tricks[1].add(player: east, card: Card.new(rank: ACE, suit: SPADES))
      tricks[1].add(player: south, card: Card.new(rank: JOKER, suit: JOKER_SUIT))
      silence do
        puts
        result = display.tricks(
          display_order: [south, west, north, east],
          trumps: CLUBS,
          tricks: tricks,
          bidding_team: [east, west]
        )
        expect(result).to eq nil
      end
    end
  end
end
