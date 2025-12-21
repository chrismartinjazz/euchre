# frozen_string_literal: true

require_relative 'constants'
require_relative 'modules/human_player_helpers'

# comment
class HumanPlayerBidding
  include HumanPlayerHelpers

  attr_writer :name

  def initialize
    @name = 'Unknown'
  end

  def decide_bid(options:, card: nil)
    @options = options
    @card = card
    prompt = generate_bid_prompt
    valid_inputs = determine_valid_bid_inputs
    bid = parse_bid_input(get_player_input(@name, prompt, valid_inputs))
    return { bid: bid, going_alone: false } if bid == :pass

    going_alone = going_alone?
    { bid: bid, going_alone: going_alone }
  end

  def exchange_card!(card:, trumps:, hand:)
    @hand = hand
    @hand.push(card)
    prompt = "Choose a card to discard (1-#{@hand.size}):\n#{hand_text(trumps)}"
    valid_inputs = [*1..(@hand.size)]
    index = get_player_input(@name, prompt, valid_inputs).to_i - 1
    p index
    @hand.delete_at(index)
  end

  def choose_suit
    prompt = 'Choose a suit for the centre card: Clubs (C), Diamonds (D), Hearts (H) or Spades (S): '
    valid_input = %w[C D H S]
    get_player_input(@name, prompt, valid_input).to_sym
  end

  private

  def generate_bid_prompt
    if @options.length == 1
      "Bid - dealer pick up #{@card} (1) or pass (2):"
    else
      "Bid - #{option_list_text} or Pass (P):"
    end
  end

  def determine_valid_bid_inputs
    @options.length == 1 ? %w[1 2] : @options.map { |suit| suit.to_s[0] }.append('P')
  end

  def parse_bid_input(input)
    if %w[2 P].include?(input)
      :pass
    elsif input == '1'
      @options[0]
    else
      input.to_sym
    end
  end

  def option_list_text
    @options.collect do |suit|
      suit_text = SUITS[suit][:text]
      "#{suit_text} (#{suit_text[0].upcase})"
    end.join(', ')
  end

  def going_alone?
    get_player_input(@name, "Will you 'go alone'? Y/N", %w[Y N]) == 'Y'
  end
end
