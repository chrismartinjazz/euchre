# frozen_string_literal: true

require_relative 'constants'

# Displays the score
class DisplayScore
  def initialize
    @top_line = generate_top_line
    @bottom_line = generate_bottom_line
  end

  def prepare(teams:, score:)
    @teams = teams
    @score = score
  end

  def scoreboard
    team1_text = team_text(@teams[0], @score[@teams[0]])
    team2_text = team_text(@teams[1], @score[@teams[1]])
    padding = ' ' * (DISPLAY_WIDTH - 4 - team1_text.length - team2_text.length)
    puts [
      @top_line,
      "| #{team1_text}#{padding}#{team2_text} |",
      @bottom_line,
      ''
    ]
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

  def team_text(team, points)
    "#{team_names(team)}: #{points} points"
  end

  def team_names(team)
    team.map(&:to_s).join(' ')
  end
end
