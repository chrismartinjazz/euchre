# frozen_string_literal: true

require_relative 'context'
require_relative 'display'
require_relative 'player_manager'
require_relative 'deal_manager'
require_relative 'bidding_manager'
require_relative 'trick_manager'
require_relative 'score_manager'

# The game. Holds the context for the game and coordinates the game loop.
class Game
  def initialize
    @context = Context.new
    @display = Display.new

    @player_manager = PlayerManager.new
    @deal_manager = DealManager.new
    @bidding_manager = BiddingManager.new
    @trick_manager = TrickManager.new
    @score_manager = ScoreManager.new

    [@player_manager, @deal_manager, @score_manager, @display].each { |preparer| preparer.prepare(context: @context) }
  end

  def start_game_loop
    until @score_manager.game_over?(context: @context)
      @deal_manager.deal(context: @context, display: @display)
      update_display
      @bidding_manager.handle_bidding(context: @context, display: @display)
      unless @context.bid.pass
        @trick_manager.play_hand(context: @context, display: @display)
        @score_manager.update_score(context: @context, display: @display)
      end
      @deal_manager.rotate_player_order(context: @context, display: @display)
    end
    display_end_game_messages
  end

  private

  def update_display
    @display.clear_screen
    @display.score(context: @context)
    @display.players(context: @context)
  end

  def display_end_game_messages
    @display.message(message: 'Game Over!')
    @display.score
  end
end
