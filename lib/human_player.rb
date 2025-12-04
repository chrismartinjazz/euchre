# frozen_string_literal: true

require_relative 'player'
require_relative 'suits'

# A human player
class HumanPlayer < Player
  def initialize(name: 'Unknown')
    super
  end

  def bid_centre_card(centre_card)
    prompt = "Bid - dealer pick up #{centre_card} (1) or pass (2):"
    input = get_upcase_input(prompt, %w[1 2], "Type '1' or '2'")
    return 'pass', false if input == '2'

    ['pick up', going_alone?]
  end

  def bid_trumps(available_trumps)
    available_trumps_list = available_trumps.collect { |trump| text_with_option(SUITS[trump][:text]) }.join(', ')
    available_trumps_list += ' or Pass (P)'
    prompt = "Bid - #{available_trumps_list}:"
    valid_inputs = available_trumps.map(&:to_s) + ['P']

    bid = get_upcase_input(prompt, valid_inputs)
    return 'pass' if bid == 'P'

    [bid.to_sym, going_alone?]
  end

  def text_with_option(text)
    "#{text} (#{text[0].upcase})"
  end

  def exchange_card(card, _trumps)
    @hand.push(card)
    prompt = "Choose a card to discard (1-6):\n#{hand_text}\n#{number_options_text(6)}"
    index = get_upcase_input(prompt, %w[1 2 3 4 5 6], 'Enter a number from 1 to 6.').to_i - 1
    @hand.delete_at(index)
  end

  def play_card(trumps, tricks, trick_index)
    # Determine the cards that can be played, then choose one of the available cards.
    current_trick = tricks[trick_index]
    lead_suit = current_trick.lead_suit
    can_follow_suit = @hand.any? { |card| card.suit(trumps) == lead_suit }
    valid_hand_indices = []

    # Determine which card indices from the player's hand can be played.
    if can_follow_suit
      @hand.each_with_index { |card, index| valid_hand_indices.push(index) if card.suit(trumps) == lead_suit }
    else
      valid_hand_indices = [*0..(@hand.length - 1)]
    end
    valid_hand_input = valid_hand_indices.map { |card| (card + 1).to_s}

    prompt = "Choose a card to play (1-#{@hand.length}):\n#{hand_text}\n#{number_options_text(@hand.length)}"
    index = get_upcase_input(prompt, valid_hand_input, 'Choose a valid card to play.').to_i - 1
    @hand.delete_at(index)
  end

  def hand_text
    "|#{@hand.join(' |')}"
  end

  def number_options_text(max)
    output = " 1"
    return output if max == 1

    2.upto(max) { |number| output += "   #{number}" }
    output
  end

  def choose_a_suit
    suit_options = SUITS.except(:J).each_with_object([]) { |(key, value), array| array << "#{key}(#{value[:glyph]}) " }
    prompt = "Choose a suit for the centre card: #{suit_options.join(' ')}"
    valid_suit_input = SUITS.except(:J).each_with_object([]) { |(key, value), object| object << key.to_s.slice(0) }

    get_upcase_input(prompt, valid_suit_input).to_sym
  end

  def going_alone?
    get_upcase_input("Will you 'go alone'? Y/N", %w[Y N]) == 'Y'
  end

  def get_upcase_input(prompt, valid_input, invalid_input_message = nil, input_length = 1)
    invalid_input_message = "Try again! Options are #{valid_input.join(', ')}" if invalid_input_message.nil?

    loop do
      print "\n** #{@name} **\n#{prompt}\n>> "
      input = gets.chomp[input_length - 1].upcase
      return input if valid_input.include?(input)

      puts invalid_input_message
    end
  end
end
