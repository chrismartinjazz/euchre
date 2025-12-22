# frozen_string_literal: true

require_relative 'constants'
require_relative 'player'
require_relative 'human_player_bidding'
require_relative 'human_player_tricks'

# A human player. Holds a hand of cards. Manages the player interface,
# forwarding messages to HumanPlayerBidding and HumanPlayerTricks.
class HumanPlayer < Player
  def initialize(name: 'Unknown', bidding: HumanPlayerBidding.new, tricks: HumanPlayerTricks.new)
    super
    @bidding = bidding
    @bidding.name = name
    @tricks = tricks
    @tricks.name = name
  end

  def decide_bid(options:, card: nil, **_keyword_args)
    @bidding.decide_bid(options: options, card: card)
  end

  def exchange_card!(card:, trumps:, hand: nil)
    my_hand = hand || @hand
    @bidding.exchange_card!(hand: my_hand, card: card, trumps: trumps)
  end

  def choose_a_suit
    @bidding.choose_a_suit
  end

  def play_card(trumps:, tricks:, trick_index:, hand: nil)
    my_hand = hand || @hand
    @tricks.play_card(trumps: trumps, tricks: tricks, trick_index: trick_index, hand: my_hand)
  end
end
