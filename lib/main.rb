# frozen_string_literal: true

require_relative 'trick_manager'
require_relative 'deck'
require_relative 'human_player'
require_relative 'ranks'

deck = Deck.new(ranks: RANKS[:non_trumps], joker_count: 1)
deck.shuffle

south = HumanPlayer.new(name: 'South')
west = HumanPlayer.new(name: 'West')
north = HumanPlayer.new(name: 'North')
east = HumanPlayer.new(name: 'East')
player_order = [south, west, north, east]
player_teams = { north: :north_south, south: :north_south, east: :east_west, west: :east_west }

player_order.each { |player| player.hand = deck.deal(5) }
bidder = east
bidding_team = :east_west
defending_team = :north_south
trumps = :C

trick_manager = TrickManager.new(trumps)
trick_manager.play_hand(false, bidding_team, defending_team, player_order, player_teams)
