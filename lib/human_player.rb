# frozen_string_literal: true

require_relative 'constants'
require_relative 'player'
require_relative 'human_player_bidding'

# A human player
class HumanPlayer < Player
  def initialize(name: 'Unknown', bidding: HumanPlayerBidding.new)
    super
    @bidding = bidding
    @bidding.name = name
  end

  def decide_bid(options:, card: nil, **_keyword_args)
    @bidding.decide_bid(options: options, card: card)
  end

  def exchange_card!(card:, trumps:, hand: nil)
    my_hand = hand || @hand
    @bidding.exchange_card!(hand: my_hand, card: card, trumps: trumps)
  end

  def choose_suit
    @bidding.choose_suit
  end

  def play_card(trumps:, tricks:, trick_index:)
    valid_card_numbers = find_valid_card_numbers(trumps, tricks, trick_index)
    prompt = "Choose a card to play (1-#{@hand.length}):\n#{hand_text(trumps)}\n#{number_options_text(@hand.length)}"
    chosen_card_number = get_input(prompt, valid_card_numbers).to_i
    @hand.delete_at(chosen_card_number - 1)
  end

  def find_valid_card_numbers(trumps, tricks, trick_index)
    lead_suit = tricks[trick_index].lead_suit
    can_follow_suit = @hand.any? { |card| card.suit(trumps: trumps) == lead_suit }
    valid_hand_indices = []
    if can_follow_suit
      @hand.each_with_index { |card, index| valid_hand_indices.push(index) if card.suit(trumps: trumps) == lead_suit }
    else
      valid_hand_indices = [*0..(@hand.length - 1)]
    end
    valid_hand_indices.map { |card| (card + 1).to_s }
  end

  private

  def hand_text(trumps)
    "|#{@hand.map { |card| card.to_s(trumps: trumps) }.join(' |')}"
  end

  def number_options_text(max)
    output = ' 1'
    return output if max == 1

    2.upto(max) { |number| output += "   #{number}" }
    output
  end

  def get_input(prompt, valid_input, invalid_input_message = nil)
    normalized_valid_input = valid_input.map { |option| option.to_s[0].upcase }
    invalid_input_message = "Try again! Options are #{normalized_valid_input.join(', ')}" if invalid_input_message.nil?

    loop do
      print "\n** #{@name} **\n#{prompt}\n>> "
      input = gets.chomp[0]&.upcase
      return input if normalized_valid_input.include?(input)

      puts invalid_input_message
    end
  end
end
