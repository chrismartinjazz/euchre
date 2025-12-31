# frozen_string_literal: true

module Euchre
  module Players
    # Get input from a player through the terminal. Requires a single upper-cased character option input
    module HumanPlayerHelpers
      def get_player_input(name, prompt, options)
        my_options = normalize_options(options)
        loop do
          display_prompt(name, prompt)
          input = single_upcase_character
          return input if my_options.include?(input)

          display_valid_options(options)
        end
      end

      # e.g. "|TD |9H |3D |JS |J? |"
      #      " 1   2   3   4   5"
      def hand_text(hand, trumps)
        hand_string = "|#{hand.map { |card| card.to_s(trumps: trumps) }.join(' |')} |"
        numbers_string = 1.upto(hand.length).with_object([]) { |number, array| array << "#{number}   " }.join.strip
        "#{hand_string}\n #{numbers_string}"
      end

      private

      def normalize_options(options)
        options.map { |option| option.to_s[0].upcase }.uniq
      end

      def display_prompt(name, prompt)
        print "\n** #{name} **\n#{prompt}\n>> "
      end

      def single_upcase_character
        gets.chomp.lstrip[0]&.upcase
      end

      def display_valid_options(options)
        puts "Options are #{options.join(', ')}"
      end
    end
  end
end
