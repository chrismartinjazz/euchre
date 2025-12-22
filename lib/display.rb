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
    @face_down_card = Card.for(rank: '', suit: '')
  end

  def prepare(display_order:, teams:, score:)
    @display_score.prepare(teams: teams, score: score)
    @display_players.prepare(display_order: display_order)
    @display_tricks.prepare(display_order: display_order)
  end

  def clear_screen
    system('cls') || system('clear')
  end

  def score
    @display_score.scoreboard
  end

  def players(dealer:, centre_card: @face_down_card, centre_card_suit: @face_down_card.suit)
    @display_players.grid(dealer: dealer, centre_card: centre_card, centre_card_suit: centre_card_suit)
  end

  def tricks(trumps:, tricks:, bidders:)
    @display_tricks.table(trumps: trumps, tricks: tricks, bidders: bidders)
  end

  def message(message: '', confirmation: false)
    confirmation_text = confirmation ? ' Press Enter to continue...' : ''
    puts "#{message}#{confirmation_text}".strip
    gets if confirmation
  end
end
