# frozen_string_literal: true

require_relative 'game'

game = Game.new
game.start_game_loop

# Testing TrickManager
# require_relative 'trick_manager'
# require_relative 'deck'
# require_relative 'human_player'
# require_relative 'ranks'

# deck = Deck.new(ranks: RANKS[:non_trumps], joker_count: 1)
# deck.shuffle

# south = HumanPlayer.new(name: 'South')
# west = HumanPlayer.new(name: 'West')
# north = HumanPlayer.new(name: 'North')
# east = HumanPlayer.new(name: 'East')
# player_order = [south, west, north, east]

# player_order.each { |player| player.hand = deck.deal(5) }
# bidding_team = [east, west]
# trumps = :C

# trick_manager = TrickManager.new(trumps)
# result = trick_manager.play_hand(false, bidding_team, player_order)
# p result
