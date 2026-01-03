# frozen_string_literal: true

require_relative '../constants'

module Euchre
  module Players
    # Helpers for Computer Player class and related classes.
    module ComputerPlayerHelpers
      include Euchre::Constants

      def announce(name, input, confirmation: false)
        string = input.is_a?(Array) ? input.join(' ') : input
        think
        puts "\n#{name}: #{string} #{'Press Enter to continue...' if confirmation}".strip
        wait_for_user_to_press_enter if confirmation
      end

      private

      def think
        sleep(THINKING_TIME)
      end

      def wait_for_user_to_press_enter
        gets
      end
    end
  end
end
