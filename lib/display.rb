# frozen_string_literal: true

require_relative 'constants'
require_relative 'display_tricks'
require_relative 'display_players'

# Handle displaying the game
class Display
  def initialize(players:, score:)
    @display_players = DisplayPlayers.new(players: players)
    @display_tricks = DisplayTricks.new(players: players)
    @score = score
    @face_down_card = Card.new(rank: '', suit: '')
  end

  def score
    team1, team2 = @score.keys
    team1_text = "#{team_names(team1)}: #{@score[team1]} points"
    team2_text = "#{team_names(team2)}: #{@score[team2]} points"
    score_text = "| #{team1_text}#{' ' * (56 - team1_text.length - team2_text.length)}#{team2_text} |"
    puts "#{'*' * 24} SCOREBOARD #{'*' * 24}"
    puts score_text
    puts "#{'*' * 60}"
    puts
  end

  def players(dealer:, centre_card: @face_down_card, centre_card_suit: @face_down_card.suit)
    @display_players.players(dealer: dealer, centre_card: centre_card, centre_card_suit: centre_card_suit)
  end

  def tricks(trumps:, tricks:, bidding_team:)
    @display_tricks.table(
      trumps: trumps,
      tricks: tricks,
      bidding_team: bidding_team
    )
  end

  def confirm_next_round(dealer:, confirmation: false)
    puts "New dealer is #{dealer}. Reshuffling... Press Enter to deal."
    gets if confirmation
  end

  def hand_result(winning_team:, points:)
    points_text = points > 1 ? "#{points} points" : "#{points} point"
    puts "#{team_names(winning_team)} wins that hand, scoring #{points_text}."
  end

  def message(message: '', confirmation: false)
    confirmation_text = confirmation ? ' Press Enter to continue...' : ''
    puts "#{message}#{confirmation_text}".strip
    gets if confirmation
  end

  def clear_screen
    system('cls') || system('clear')
  end

  private

  def team_names(team)
    team.map(&:to_s).join(' ')
  end
end
