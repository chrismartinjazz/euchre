# frozen_string_literal: true

require_relative 'card'
require_relative 'computer_player'
require_relative 'constants'
require_relative 'deck'
require_relative 'display'
require_relative 'human_player'
require_relative 'player'
require_relative 'trick_manager'

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
    @face_down_card = Card.new(rank: '', suit: '')
  end

  def start_game_loop
    loop do
      @display.clear_screen
      rotate_player_order_to_start_with(player_after(@dealer))
      deal
      @display.score
      @display.players(dealer: @dealer, centre_card: @centre_card, centre_card_suit: @centre_card_suit)
      trumps, bidder, going_alone = bid_for_trumps

      if trumps.nil?
        @dealer = player_after(@dealer)
        @display.confirm_next_round(dealer: @dealer)
        next
      end

      bidding_team, defending_team = set_teams(bidder, going_alone)
      trick_player_order = set_trick_player_order(bidding_team, defending_team)

      trick_manager = TrickManager.new(
        display: @display,
        trumps: trumps,
        going_alone: going_alone,
        bidding_team: bidding_team,
        player_order: trick_player_order
      )
      trick_manager.play_hand
      winner = trick_manager.winner
      points = trick_manager.points
      winning_team = winner == 'bidders' ? bidding_team : defending_team
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

  # Return the bidded trump suit and the bidder (player object) or nil if all pass twice.
  def bid_for_trumps
    @player_order.each do |player|
      response = player.bid_centre_card(card: @centre_card, suit: @centre_card_suit, dealer: player == @dealer)
      next if response[:bid] == :pass

      trumps = response[:bid]
      going_alone = response[:going_alone]

      @dealer.exchange_card(card: @centre_card, trumps: trumps)
      return trumps, player, going_alone
    end

    # If all players have passed... the centre card is turned down. Remaining suits can be chosen as trumps.
    @display.message(message: "#{@dealer}: I turn it down.", confirmation: true)
    available_trumps = SUITS.keys.reject { |suit| [JOKER_SUIT, @centre_card_suit].include?(suit) }
    @display.clear_screen
    @display.score
    @display.players(dealer: @dealer, centre_card: @face_down_card, centre_card_suit: @face_down_card.suit)

    @player_order.each do |player|
      response = player.bid_trumps(options: available_trumps)
      next if response[:bid] == :pass

      trumps = response[:bid]
      going_alone = response[:going_alone]

      return trumps, player, going_alone
    end

    # If all players have passed again...
    nil
  end

  def set_teams(bidder, going_alone)
    bidding_team = if going_alone
                     [bidder]
                   elsif @team1.include?(bidder)
                     @team1
                   else
                     @team2
                   end
    defending_team = @team1.include?(bidding_team[0]) ? @team2 : @team1
    [bidding_team, defending_team]
  end

  def set_trick_player_order(bidding_team, defending_team)
    @player_order.filter { |player| (bidding_team + defending_team).include?(player) }
  end

  def game_over?
    @score[@team1] >= POINTS_TO_WIN_GAME || @score[@team2] >= POINTS_TO_WIN_GAME
  end
end
