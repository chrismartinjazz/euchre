# frozen_string_literal: true

require_relative '../game_state'
require_relative '../players'

module Euchre
  module Managers
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
        context.players = GameState::Players.new(
          south: Players::HumanPlayer.new(name: 'South'),
          west: Players::ComputerPlayer.new(name: 'West'),
          north: Players::ComputerPlayer.new(name: 'North'),
          east: Players::ComputerPlayer.new(name: 'East')
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
  end
end
