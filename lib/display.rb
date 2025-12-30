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
  end

  def prepare(context:)
    @display_tricks.prepare(context: context)
  end

  def clear_screen
    system('cls') || system('clear')
  end

  def score(context:)
    @display_score.scoreboard(context: context)
  end

  def players(context:)
    @display_players.grid(context: context)
  end

  def tricks(context:)
    @display_tricks.table(context: context)
  end

  def message(message: '', confirmation: false)
    confirmation_text = confirmation ? ' Press Enter to continue...' : ''
    puts "#{message}#{confirmation_text}".strip
    gets if confirmation
  end
end
