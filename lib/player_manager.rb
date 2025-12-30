# frozen_string_literal: true

require_relative 'players'
require_relative 'human_player'
require_relative 'computer_player'

# Manages Players
class PlayerManager
  def prepare(context:)
    initialize_players(context)
    initialize_teams(context)
    initialize_player_order_and_dealer(context)
    context
  end

  private

  def initialize_players(context)
    context.players = Players.new(
      south: HumanPlayer.new(name: 'South'),
      west: ComputerPlayer.new(name: 'West'),
      north: ComputerPlayer.new(name: 'North'),
      east: ComputerPlayer.new(name: 'East')
    )
  end

  def initialize_teams(context)
    context.players.team1 = [context.players.south, context.players.north]
    context.players.team2 = [context.players.west, context.players.east]
  end

  def initialize_player_order_and_dealer(context)
    context.display_order = [
      context.players.south,
      context.players.west,
      context.players.north,
      context.players.east
    ].freeze
    context.player_order = context.display_order.dup
    context.dealer = context.display_order.last
  end
end
