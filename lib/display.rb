# frozen_string_literal: true

require_relative 'constants'
require_relative 'display_score'
require_relative 'display_tricks'
require_relative 'display_players'

# Handle displaying the game
class Display
  def initialize
    @display_score = DisplayScore.new
    @display_players = DisplayPlayers.new
    @display_tricks = DisplayTricks.new
    @face_down_card = Card.new(rank: '', suit: '')
  end

  def clear_screen
    system('cls') || system('clear')
  end

  def score(teams: nil, score: nil)
    @display_score.scoreboard(teams: teams, score: score)
  end

  def players(dealer:, centre_card: @face_down_card, centre_card_suit: @face_down_card.suit, players: nil)
    @display_players.grid(dealer: dealer, centre_card: centre_card, centre_card_suit: centre_card_suit, players: players)
  end

  def tricks(trumps:, tricks:, bidders:, players: nil)
    @display_tricks.table(trumps: trumps, tricks: tricks, bidders: bidders, players: players)
  end

  def message(message: '', confirmation: false)
    confirmation_text = confirmation ? ' Press Enter to continue...' : ''
    puts "#{message}#{confirmation_text}".strip
    gets if confirmation
  end
end
