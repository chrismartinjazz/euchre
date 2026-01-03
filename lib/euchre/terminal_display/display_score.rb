# frozen_string_literal: true

require_relative '../constants'
require_relative 'graphics'

module Euchre
  module TerminalDisplay
    # Displays the score
    class DisplayScore
      include TerminalDisplay::Graphics
      include TerminalGrid

      def grid(context:)
        title = Cell.new(contents: TITLE, justified: :center, width: 34)
        team1, team2 = teams(context)
        team1_names, team1_score = generate_team_cells(context, team1, :black, :left)
        team2_names, team2_score = generate_team_cells(context, team2, :red, :right)
        my_grid = Grid.new(
          grid: [
            [team1_names, team2_names],
            [team1_score, title, team2_score]
          ],
          border: Border.new(horizontal: '', vertical: '', corner: '')
        )
        puts my_grid
      end

      private

      def teams(context)
        [context.players.team1, context.players.team2]
      end

      def generate_team_cells(context, team, color, justified)
        names = Cell.new(contents: team_names(team), justified: justified)
        score = Cell.new(contents: SCORE[color][context.score[team]], justified: justified)
        [names, score]
      end

      def team_names(team)
        team.map(&:to_s).join(' ')
      end
    end
  end
end
