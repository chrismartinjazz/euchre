# frozen_string_literal: true

require_relative 'constants'
require_relative 'card'
require_relative 'deck'

# Manages the deck and dealing.
class DealManager
  attr_reader :player_order, :dealer, :centre_card, :centre_card_suit

  def initialize(display:, player_order:, dealer: nil)
    @display = display
    @player_order = player_order
    @dealer = dealer.nil? ? player_order[rand(0..(player_order.length - 1))] : dealer
  end

  def deal
    deck = Deck.new(ranks: RANKS[:non_trumps], joker_count: 1)
    deck.shuffle
    @player_order.each(&:reset_hand)
    @player_order.each { |player| player.add_to_hand(cards: deck.deal(count: 5)) }
    @centre_card = deck.draw_one
    @centre_card_suit = @centre_card.suit == JOKER_SUIT ? handle_centre_card_is_joker : @centre_card.suit
  end

  def rotate_player_order
    @dealer = player_after(@dealer)
    rotate_player_order_to_start_with(player_after(@dealer))
    @display.message(message: "New dealer is #{@dealer}. Reshuffling . . . ", confirmation: true)
  end

  private

  def handle_centre_card_is_joker
    @display.message(
      message: 'The turned up card is a joker! The dealer must choose a trump suit before looking at their hand.'
    )
    suit = @dealer.choose_a_suit
    @display.message(message: '', confirmation: true)
    suit
  end

  def player_after(player)
    player_index = @player_order.find_index(player)
    return @player_order[0] if player_index == @player_order.length - 1

    @player_order[player_index + 1]
  end

  def rotate_player_order_to_start_with(starting_player)
    @player_order.rotate!(@player_order.find_index(starting_player))
  end
end
