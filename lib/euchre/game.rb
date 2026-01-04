# frozen_string_literal: true

module Euchre
  # The game. Holds the context for the game and coordinates the game loop.
  class Game
    def initialize
      @context = GameState::Context.new
      @display = TerminalDisplay::Display.new

      @player_manager = Managers::PlayerManager.new
      @deal_manager = Managers::DealManager.new
      @bidding_manager = Managers::BiddingManager.new
      @trick_manager = Managers::TrickManager.new
      @score_manager = Managers::ScoreManager.new

      [@player_manager, @deal_manager, @score_manager].each { |preparer| preparer.prepare(context: @context) }
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
end
