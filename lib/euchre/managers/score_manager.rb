# frozen_string_literal: true

module Euchre
  module Managers
    # Manages updating the score and determining if the game is over
    class ScoreManager
      POINTS_TO_WIN_GAME = 11

      def prepare(context:)
        context.score = { context.players.team1 => 0, context.players.team2 => 0 }
      end

      def update_score(context:, display:)
        winners = context.result.winners
        points = context.result.points
        context.score[winners] += points
        points_text = points > 1 ? "#{points} points" : "#{points} point"
        display.message(message: "#{team_names(winners)} wins that hand, scoring #{points_text}.", confirmation: true)
      end

      def game_over?(context:)
        context.score[context.players.team1] >= POINTS_TO_WIN_GAME ||
          context.score[context.players.team2] >= POINTS_TO_WIN_GAME
      end

      private

      def team_names(team)
        team.map(&:to_s).join(' ')
      end
    end
  end
end
