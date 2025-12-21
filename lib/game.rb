# frozen_string_literal: true

require_relative 'human_player'
require_relative 'computer_player'
require_relative 'deck'
require_relative 'display'
require_relative 'deal_manager'
require_relative 'trick_manager'
require_relative 'bidding_manager'
require_relative 'score_manager'

# The game.
class Game
  def initialize
    south = HumanPlayer.new(name: 'South')
    west = ComputerPlayer.new(name: 'West')
    north = ComputerPlayer.new(name: 'North')
    east = ComputerPlayer.new(name: 'East')
    @display_order = [south, west, north, east].freeze
    team1 = [south, north]
    team2 = [east, west]

    @display = Display.new
    @deal_manager = DealManager.new(display: @display, player_order: @display_order.dup, dealer: east)
    @bidding_manager = BiddingManager.new(display: @display, team1: team1, team2: team2)
    @trick_manager = TrickManager.new(display: @display)
    @score_manager = ScoreManager.new(display: @display, team1: team1, team2: team2)

    @display.prepare(display_order: @display_order, teams: [team1, team2], score: @score_manager.score)
  end

  def start_game_loop
    loop do
      @deal_manager.deal
      update_display
      @bidding_manager.handle_bidding(
        player_order: @deal_manager.player_order,
        centre_card: @deal_manager.centre_card,
        centre_card_suit: @deal_manager.centre_card_suit
      )

      if @bidding_manager.bid == :pass
        @deal_manager.rotate_player_order
        next
      end

      @trick_manager.play_hand(
        trumps: @bidding_manager.bid,
        going_alone: @bidding_manager.going_alone,
        bidders: @bidding_manager.bidders,
        defenders: @bidding_manager.defenders,
        player_order: @bidding_manager.player_order
      )

      @score_manager.update_score(winner: @trick_manager.winner, points: @trick_manager.points)
      break if @score_manager.game_over?

      @deal_manager.rotate_player_order
    end

    @display.message(message: 'Game Over!')
    @display.score
  end

  private

  def update_display
    @display.clear_screen
    @display.score
    @display.players(
      dealer: @deal_manager.dealer,
      centre_card: @deal_manager.centre_card,
      centre_card_suit: @deal_manager.centre_card_suit
    )
  end
end
