# frozen_string_literal: true

# Data structures to hold data and objects relevant to phases of the game
require_relative 'game_state/bid'
require_relative 'game_state/players'
require_relative 'game_state/result'

require_relative 'game_state/context'

# Data structures that hold all aspects of the game state. Context holds instances of the other data structures
# (Players, Bid, Result)
module GameState
end
