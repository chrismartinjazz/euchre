# frozen_string_literal: true

require_relative './deck'
require_relative './card'
require_relative './player'
require_relative './human_player'
require_relative './computer_player'

# The game
class Game
  def initialize
    @south = HumanPlayer.new(name: 'South')
    @west = HumanPlayer.new(name: 'West')
    @north = HumanPlayer.new(name: 'North')
    @east = HumanPlayer.new(name: 'East')
    @player_order = [@south, @west, @north, @east]
    @dealer = @east
    @score = { north_south: 0, east_west: 0 }
    game_loop
  end

  def game_loop
    loop do
      # TODO: check for winner
      deal
      display_board
      trump_suit = bid_for_trumps
      next unless trump_suit

      puts trump_suit
    end
  end

  def deal
    @deck = Deck.new(ranks: %w[9 T J Q K A], joker_count: 1)
    @player_order.each(&:reset_hand)
    @deck.shuffle
    @player_order.each do |player|
      player.hand = @deck.deal(5)
    end
    @centre_card = @deck.deal(1)[0]
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
  end

  def bid_for_trumps
    # Return the trump as a symbol (:C) or nil
    bidding_order = player_order_starting_with(player_after(@dealer))
    bidding_order.each do |player|
      player_bid = player.bid_centre_card(@centre_card) # 'pick up' or 'pass'
      next unless player_bid == 'pick up'

      trumps = @centre_card.suit
      @dealer.exchange_card(@centre_card, trumps)
      return trumps
    end

    available_trumps = %i[C D S H]
    available_trumps.delete(@centre_card.suit)
    bidding_order.each do |player|
      player_bid = player.bid_trumps(available_trumps)
      next if player_bid == 'pass'

      return player_bid
    end

    nil
  end

  def player_after(player)
    player_index = @player_order.find_index(player)
    return @player_order[0] if player_index == @player_order.length - 1

    player_order[player_index + 1]
  end

  def player_order_starting_with(starting_player)
    order = @player_order.dup
    order.find_index(starting_player).times { order.push(order.unshift) }
    order
  end
end

game = Game.new
