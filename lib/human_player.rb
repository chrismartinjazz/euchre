# frozen_string_literal: true

require_relative 'constants'
require_relative 'player'

# A human player
class HumanPlayer < Player
  def initialize(name: 'Unknown')
    super
  end

  def bid_centre_card(card:, suit:, **_keyword_args)
    prompt = "Bid - dealer pick up #{card} (1) or pass (2):"
    input = get_upcase_input(prompt, %w[1 2])

    bid = input == '1' ? suit : :pass
    going_alone = bid == :pass ? false : going_alone?

    {bid: bid, going_alone: going_alone}
  end

  def bid_trumps(options:)
    option_list = options.collect { |trump| text_with_option(SUITS[trump][:text]) }.join(', ')
    option_list += ' or Pass (P)'
    prompt = "Bid - #{option_list}:"
    valid_inputs = options.map { |trump| trump.to_s[0] } + ['P']
    input = get_upcase_input(prompt, valid_inputs)

    bid = input == 'P' ? :pass : input.to_sym
    going_alone = bid == :pass ? false : going_alone?

    {bid: bid, going_alone: going_alone}
  end

  def exchange_card(card:, **_keyword_args)
    @hand.push(card)
    prompt = "Choose a card to discard (1-6):\n#{hand_text}\n#{number_options_text(6)}"
    index = get_upcase_input(prompt, %w[1 2 3 4 5 6], 'Enter a number from 1 to 6.').to_i - 1
    @hand.delete_at(index)
  end

  def play_card(trumps:, tricks:, trick_index:)
    valid_card_numbers = find_valid_card_numbers(trumps, tricks, trick_index)
    prompt = "Choose a card to play (1-#{@hand.length}):\n#{hand_text}\n#{number_options_text(@hand.length)}"
    chosen_card_number = get_upcase_input(prompt, valid_card_numbers).to_i
    @hand.delete_at(chosen_card_number - 1)
  end

  def choose_a_suit
    suit_options = SUITS.except(JOKER_SUIT).each_with_object([]) do |(key, value), array|
      array << "#{key}(#{value[:glyph]}) "
    end
    prompt = "Choose a suit for the centre card: #{suit_options.join(' ')}"
    valid_suit_input = SUITS.except(JOKER_SUIT).each_with_object([]) do |(key, _value), array|
      array << key.to_s.slice(0)
    end

    input = get_upcase_input(prompt, valid_suit_input)
    input.to_sym
  end

  private

  def text_with_option(text)
    "#{text} (#{text[0].upcase})"
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

  def hand_text
    "|#{@hand.join(' |')}"
  end

  def number_options_text(max)
    output = ' 1'
    return output if max == 1

    2.upto(max) { |number| output += "   #{number}" }
    output
  end

  def going_alone?
    get_upcase_input("Will you 'go alone'? Y/N", %w[Y N]) == 'Y'
  end

  def get_upcase_input(prompt, valid_input, invalid_input_message = nil)
    normalized_valid_input = valid_input.map { |option| option.to_s[0].upcase }
    invalid_input_message = "Try again! Options are #{normalized_valid_input.join(', ')}" if invalid_input_message.nil?

    loop do
      print "\n** #{@name} **\n#{prompt}\n>> "
      input = gets.chomp[0].upcase
      return input if normalized_valid_input.include?(input)

      puts invalid_input_message
    end
  end
end
