# frozen_string_literal: true

# Manages updating the score and determining if the game is over
class ScoreManager
  attr_reader :score, :team1, :team2

  def initialize(display:, team1:, team2:)
    @display = display
    @team1 = team1
    @team2 = team2
    @points_to_win_game = 11
    @score = { @team1 => 0, @team2 => 0 }
  end

  def update_score(winner:, points:)
    @score[winner] += points
    points_text = points > 1 ? "#{points} points" : "#{points} point"
    @display.message(message: "#{team_names(winner)} wins that hand, scoring #{points_text}.", confirmation: true)
  end

  def game_over?
    @score[@team1] >= @points_to_win_game || @score[@team2] >= @points_to_win_game
  end

  private

  def team_names(team)
    team.map(&:to_s).join(' ')
  end
end
