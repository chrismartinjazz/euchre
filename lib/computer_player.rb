# frozen_string_literal: true

require_relative 'constants'
require_relative 'player'
require_relative 'computer_player_bidding'
require_relative 'computer_player_tricks'

# A computer player.
class ComputerPlayer < Player
  def initialize(name: 'Unknown', bidding: ComputerPlayerBidding.new, tricks: ComputerPlayerTricks.new)
    super
    @bidding = bidding
    @bidding.name = name
    @tricks = tricks
    @tricks.name = name
  end

  def decide_bid(options:, hand: nil, card: nil, dealer: nil)
    my_hand = hand || @hand
    @bidding.decide_bid(hand: my_hand, options: options, card: card, dealer: dealer)
  end

  def exchange_card!(card:, trumps:, hand: nil)
    my_hand = hand || @hand
    @bidding.exchange_card!(card: card, trumps: trumps, hand: my_hand)
  end

  def choose_a_suit
    @bidding.choose_a_suit
  end

  def play_card(trumps:, tricks:, trick_index:, hand: nil)
    my_hand = hand || @hand
    @tricks.play_card(trumps: trumps, tricks: tricks, trick_index: trick_index, hand: my_hand)
  end
end
