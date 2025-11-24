# frozen_string_literal: true

require 'deck'
require 'card'
require 'ranks'
require 'player'
require 'human_player'
require 'computer_player'
require 'hand_manager'

# The game
class Game
  def initialize
    @south = HumanPlayer.new(name: 'South')
    @west = HumanPlayer.new(name: 'West')
    @north = HumanPlayer.new(name: 'North')
    @east = HumanPlayer.new(name: 'East')
    @player_order = [@south, @west, @north, @east]
    @player_teams = { north: :north_south, south: :north_south, east: :east_west, west: :east_west }
    @dealer = @east
    @score = { north_south: 0, east_west: 0 }
    # Break the logic for managing the progress of an individual hand into a separate object, HandManager
  end

  def start_game_loop
    loop do
      # TODO: check for winner
      deal
      display_board
      trumps, bidder = bid_for_trumps
      if trumps.nil?
        @dealer = player_after(@dealer)
        next
      end

      bidding_team = @player_teams[bidder]
      @trick_manager = TrickManager.new(trumps, bidder, bidding_team, @player_order, @player_teams)
      display_board
      # TODO: Add "bidder goes alone"
      result = @trick_manager.play_tricks(@bidding_team)
      handle_result(result)

      @dealer = player_after(@dealer)
    end
  end

  def deal
    @deck = Deck.new(ranks: RANKS[:non_trumps], joker_count: 1)
    @player_order.each(&:reset_hand)
    @deck.shuffle
    @player_order.each do |player|
      player.hand = @deck.deal(5)
    end
    @centre_card = @deck.draw_one
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
    puts "Trumps: #{@trumps}"
    puts "Bidder: #{@bidder}"
  end

  # Return the trump as a symbol (:C) or nil
  def bid_for_trumps
    # TODO: Handle the case where the centre_card is the joker
    bidding_order = player_order_starting_with(player_after(@dealer))
    bidding_order.each do |player|
      player_bid = player.bid_centre_card(@centre_card) # 'pick up' or 'pass'
      next if player_bid == 'pass'

      trumps = @centre_card.suit
      @dealer.exchange_card(@centre_card, trumps)
      return trumps, player
    end

    available_trumps = %i[C D S H]
    available_trumps.delete(@centre_card.suit)
    bidding_order.each do |player|
      player_bid = player.bid_trumps(available_trumps)
      next if player_bid == 'pass'

      trumps = player_bid
      return trumps, player
    end

    nil
  end





  def rank_cards
    # If trumps is led:
    # Joker
    # J of trump suit
    # J of same color
    # A
    # K
    # Q
    # T
    # 9
    # ---
    # all others.
    #
    # If another suit is led:
    # Joker
    # J of trump suit
    # J of same color
    # A
    # K
    # Q
    # T
    # 9
    # ---
    # A of lead suit
    # K
    # Q
    # J
    # T
    # 9
    # ---
    # all others

    #
  end

  def player_after(player)
    player_index = @player_order.find_index(player)
    return @player_order[0] if player_index == @player_order.length - 1

    @player_order[player_index + 1]
  end

  def player_order_starting_with(starting_player)
    order = @player_order.dup
    order.find_index(starting_player).times { order.push(order.unshift) }
    order
  end
end
