# frozen_string_literal: true

require_relative '../constants'

module Euchre
  module TerminalDisplay
    # Displays the score
    class DisplayScore
      include Constants

      def initialize
        @top_line = generate_top_line
        @bottom_line = generate_bottom_line
      end

      def scoreboard(context:)
        team1_text, team2_text = generate_team_text(context)
        padding_text = generate_padding(team1_text, team2_text)
        scoreboard_text = generate_scoreboard(team1_text, team2_text, padding_text)
        puts scoreboard_text
      end

      private

      def generate_top_line
        header_text = ' SCOREBOARD '
        header_line_segment = '*' * ((DISPLAY_WIDTH - header_text.length) / 2)
        "#{header_line_segment}#{header_text}#{header_line_segment}"
      end

      def generate_bottom_line
        '*' * DISPLAY_WIDTH
      end

      def generate_team_text(context)
        team1_text = "#{team_names(context.players.team1)}: #{context.score[context.players.team1]} points"
        team2_text = "#{team_names(context.players.team2)}: #{context.score[context.players.team2]} points"
        [team1_text, team2_text]
      end

      def team_names(team)
        team.map(&:to_s).join(' ')
      end

      def generate_padding(team1_text, team2_text)
        ' ' * (DISPLAY_WIDTH - 4 - team1_text.length - team2_text.length)
      end

      def generate_scoreboard(team1_text, team2_text, padding)
        [
          @top_line,
          "| #{team1_text}#{padding}#{team2_text} |",
          @bottom_line,
          ''
        ]
      end
    end
  end
end
