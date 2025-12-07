# frozen_string_literal: true

require 'io/console'
require_relative 'constants'
require_relative 'deck'
require_relative 'card'
require_relative 'player'
require_relative 'human_player'
require_relative 'computer_player'
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
  end

  def start_game_loop
    loop do
      $stdout.clear_screen
      rotate_player_order_to_start_with(player_after(@dealer))
      deal
      display_score
      display_board
      trumps, bidder, going_alone = bid_for_trumps

      if trumps.nil?
        @dealer = player_after(@dealer)
        display_confirm_next_round
        next
      end

      bidding_team, defending_team = set_teams(bidder, going_alone)
      trick_player_order = set_trick_player_order(bidding_team, defending_team)

      trick_manager = TrickManager.new(trumps, going_alone, bidding_team, trick_player_order)
      winner, points = trick_manager.play_hand
      winning_team = winner == 'bidders' ? bidding_team : defending_team
      @score[winning_team] += points
      display_hand_result(winning_team, points)
      break if game_over?

      @dealer = player_after(@dealer)
      display_confirm_next_round
    end

    puts 'Game Over!'
    display_score
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
    @player_order.each { |player| player.hand = @deck.deal(5) }
    @centre_card = @deck.draw_one
    @centre_card_suit = @centre_card.suit == JOKER_SUIT ? handle_centre_card_is_joker : @centre_card.suit
  end

  def handle_centre_card_is_joker
    puts 'The turned up card is a joker! The dealer must choose a trump suit before looking at their hand.'
    suit = @dealer.choose_a_suit
    puts "The dealer has chosen #{SUITS[suit][:text]}."
    suit
  end

  def display_score
    puts 'SCOREBOARD'
    puts "#{team_names(@team1)}: #{@score[@team1]} points"
    puts "#{team_names(@team2)}: #{@score[@team2]} points"
  end

  def display_hand_result(winner, points)
    points_text = points > 1 ? "#{points} points" : "#{points} point"
    puts "#{team_names(winner)} wins that hand, scoring #{points_text}."
  end

  def display_board
    north_hand = ''
    @north.hand.each { |card| north_hand += "|#{card} " }
    east_hand = ''
    @east.hand.each { |card| east_hand += "|#{card} " }
    south_hand = ''
    @south.hand.each { |card| south_hand += "|#{card} " }
    west_hand = ''
    @west.hand.each { |card| west_hand += "|#{card} " }
    centre_card = @centre_card
    puts "                    #{north_hand}\n\n"
    puts "#{west_hand}         #{centre_card}           #{east_hand}\n\n"
    puts "                    #{south_hand}"
    puts "Dealer: #{@dealer}"
    puts "Centre Card Suit: #{SUITS[@centre_card_suit][:glyph]}"
  end

  def display_confirm_next_round
    puts "New dealer is #{@dealer}. Reshuffling... Press Enter to deal."
    gets
  end

  # Return the trump as a symbol (:C) and the bidder (player object) or nil if all pass twice.
  def bid_for_trumps
    @player_order.each do |player|
      player_is_dealer = player == @dealer
      player_bid, going_alone = player.bid_centre_card(@centre_card, @centre_card_suit, player_is_dealer) # 'pick up' or 'pass'
      next if player_bid == 'pass'

      trumps = @centre_card_suit
      @dealer.exchange_card(@centre_card, trumps)
      return trumps, player, going_alone
    end

    # If all players have passed... the centre card is turned down. Remaining suits can be chosen as trumps.
    puts "#{@dealer}: I turns it down."
    available_trumps = SUITS.keys.reject { |suit| [JOKER_SUIT, @centre_card_suit].include?(suit) }

    @player_order.each do |player|
      player_bid, going_alone = player.bid_trumps(available_trumps)
      next if player_bid == 'pass'

      trumps = player_bid
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

  def team_names(team)
    team.map(&:to_s).join(' ')
  end

  def game_over?
    @score[@team1] >= POINTS_TO_WIN_GAME || @score[@team2] >= POINTS_TO_WIN_GAME
  end
end
