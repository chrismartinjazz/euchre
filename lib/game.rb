# frozen_string_literal: true

require_relative 'card'
require_relative 'computer_player'
require_relative 'constants'
require_relative 'deck'
require_relative 'display'
require_relative 'human_player'
require_relative 'player'
require_relative 'trick_manager'
require_relative 'bidding_manager'

# The game
class Game
  POINTS_TO_WIN_GAME = 11

  def initialize
    @south = HumanPlayer.new(name: 'South')
    @west = ComputerPlayer.new(name: 'West')
    @north = ComputerPlayer.new(name: 'North')
    @east = ComputerPlayer.new(name: 'East')
    @player_order = [@south, @west, @north, @east]
    @team1 = [@south, @north]
    @team2 = [@east, @west]
    @dealer = @east
    @score = { @team1 => 0, @team2 => 0 }

    @display_order = @player_order.dup
    @display = Display.new(
      players: @display_order,
      score: @score
    )
  end

  def start_game_loop
    loop do
      rotate_player_order_to_start_with(player_after(@dealer))
      deal

      @display.clear_screen
      @display.score
      @display.players(dealer: @dealer, centre_card: @centre_card, centre_card_suit: @centre_card_suit)

      bidding_manager = BiddingManager.new(display: @display, team1: @team1, team2: @team2)
      bidding_manager.handle_bidding(
        player_order: @player_order,
        centre_card: @centre_card,
        centre_card_suit: @centre_card_suit
      )

      if bidding_manager.bid.nil?
        @dealer = player_after(@dealer)
        @display.confirm_next_round(dealer: @dealer)
        next
      end

      trick_manager = TrickManager.new(
        display: @display,
        trumps: bidding_manager.bid,
        going_alone: bidding_manager.going_alone,
        bidding_team: bidding_manager.bidders,
        player_order: bidding_manager.player_order
      )
      trick_manager.play_hand
      winner = trick_manager.winner
      points = trick_manager.points
      winning_team = winner == 'bidders' ? bidding_manager.bidders : bidding_manager.defenders
      @score[winning_team] += points
      @display.hand_result(winning_team: winning_team, points: points)
      break if game_over?

      @dealer = player_after(@dealer)
      @display.message(message: "New dealer is #{@dealer}. Reshuffling . . . ", confirmation: true)
    end

    @display.message(message: 'Game Over!')
    @display.score
  end

  private

  def rotate_player_order_to_start_with(starting_player)
    @player_order.rotate!(@player_order.find_index(starting_player))
  end

  def player_after(player)
    player_index = @player_order.find_index(player)
    return @player_order[0] if player_index == @player_order.length - 1

    @player_order[player_index + 1]
  end

  def deal
    @deck = Deck.new(ranks: RANKS[:non_trumps], joker_count: 1)
    @deck.shuffle
    @player_order.each(&:reset_hand)
    @player_order.each { |player| player.add_to_hand(cards: @deck.deal(count: 5)) }
    @centre_card = @deck.draw_one
    @centre_card_suit = @centre_card.suit == JOKER_SUIT ? handle_centre_card_is_joker : @centre_card.suit
  end

  def handle_centre_card_is_joker
    @display.message(message: 'The turned up card is a joker! The dealer must choose a trump suit before looking at their hand.')
    @dealer.choose_a_suit
    @display.message(message: '', confirmation: true)
  end

  def game_over?
    @score[@team1] >= POINTS_TO_WIN_GAME || @score[@team2] >= POINTS_TO_WIN_GAME
  end
end
