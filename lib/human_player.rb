# frozen_string_literal: true

require_relative './player'
require_relative './suits'

# A human player
class HumanPlayer < Player
  def initialize(name: 'Unknown')
    super(name: name)
    @trumps_text = { 'C': 'Clubs (C)', 'D': 'Diamonds (D)', 'H': 'Hearts (H)', 'S': 'Spades (S)' }
  end

  def bid_centre_card(centre_card)
    prompt = "Bid - dealer pick up #{centre_card} (1) or pass (2):"
    input = get_upcase_input(prompt, %w[1 2], "Type '1' or '2'")
    return 'pick up' if input == '1'

    'pass'
  end

  def bid_trumps(available_trumps)
    available_trumps_list = available_trumps.collect { |trump| text_with_option(SUITS[trump][:text]) }.join(', ')
    available_trumps_list += ' or Pass (P)'
    prompt = "Bid - #{available_trumps_list}:"
    valid_input_text = "Type #{available_trumps.join(', ')}, or P"
    valid_inputs = available_trumps.map(&:to_s) + ['P']

    bid = get_upcase_input(prompt, valid_inputs, valid_input_text)
    return 'pass' if bid == 'P'

    bid.to_sym
  end

  def text_with_option(text)
    "#{text} (#{text[0].upcase})"
  end

  def exchange_card(card, trumps)
    @hand.push(card)
    hand_text = ''
    @hand.each { |card| hand_text += "|#{card} " }
    prompt = "#{@name}\nChoose a card to discard (1-6):\n#{hand_text}\n 1   2   3   4   5   6"
    index = get_upcase_input(prompt, %w[1 2 3 4 5 6], 'Enter a number from 1 to 6.', 1).to_i - 1
    @hand.delete_at(index)
  end

  def get_upcase_input(prompt, valid_input, invalid_input_message = 'Try again!', input_length = 1)
    loop do
      print "** #{@name} **\n#{prompt}\n>> "
      input = gets.chomp[input_length - 1].upcase
      return input if valid_input.include?(input)

      puts invalid_input_message
    end
  end
end
