# frozen_string_literal: true

require_relative 'constants'
require_relative 'display_tricks'
require_relative 'display_bidding'

# Handle displaying the game
class Display
  def initialize(players:)
    @display_tricks = DisplayTricks.new(players: players)
    @display_bidding = DisplayBidding.new(players: players)
  end

  def score(score:)
    team1, team2 = score.keys
    score_text = "#{team_names(team1)}: #{score[team1]} points#{' ' * 10}#{team_names(team2)}: #{score[team2]} points"
    padding = '*' * ((score_text.length - 12) / 2)
    puts "#{padding} SCOREBOARD #{padding}"
    puts score_text
  end

  def bidding_grid(dealer:, centre_card:, centre_card_suit:)
    @display_bidding.grid(
      dealer: dealer,
      centre_card: centre_card,
      centre_card_suit: centre_card_suit
    )
  end

  def tricks(trumps:, tricks:, bidding_team:)
    @display_tricks.table(
      trumps: trumps,
      tricks: tricks,
      bidding_team: bidding_team
    )
  end

  def confirm_next_round(dealer:)
    puts "New dealer is #{dealer}. Reshuffling... Press Enter to deal."
    gets
  end

  def hand_result(winning_team:, points:)
    points_text = points > 1 ? "#{points} points" : "#{points} point"
    puts "#{team_names(winning_team)} wins that hand, scoring #{points_text}."
  end

  def message(message:)
    puts message
  end

  private

  def team_names(team)
    team.map(&:to_s).join(' ')
  end
end
