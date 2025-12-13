# frozen_string_literal: true

# Displays the score
class DisplayScore
  def initialize
    @teams = nil
    @score = nil
    @width = 60
    @top_line = generate_top_line
    @bottom_line = generate_bottom_line
  end

  def scoreboard(teams: nil, score: nil)
    cache(teams, score)
    team1_text = team_text(@teams[0], @score[@teams[0]])
    team2_text = team_text(@teams[1], @score[@teams[1]])
    padding = ' ' * (@width - 4 - team1_text.length - team2_text.length)
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
    header_line_segment = '*' * ((@width - header_text.length) / 2)
    "#{header_line_segment}#{header_text}#{header_line_segment}"
  end

  def generate_bottom_line
    '*' * @width
  end

  def cache(teams, score)
    @teams = teams unless teams.nil?
    @score = score unless score.nil?
  end

  def team_text(team, points)
    "#{team_names(team)}: #{points} points"
  end

  def team_names(team)
    team.map(&:to_s).join(' ')
  end
end
