# frozen_string_literal: true

# Computer Player classes
require_relative 'players/computer_player'
require_relative 'players/computer_player_bidding'
require_relative 'players/computer_player_helpers'
require_relative 'players/computer_player_tricks'

# Human Player classes
require_relative 'players/human_player'
require_relative 'players/human_player_bidding'
require_relative 'players/human_player_helpers'
require_relative 'players/human_player_tricks'

# Computer and Human Players inherit from Player
require_relative 'players/player'

# The HumanPlayer and ComputerPlayers acting in the Euchre game.
module Players
end
