# frozen_string_literal: true

require_relative '../constants'

module Euchre
  module Props
    # A playing card. Reports its rank and suit, based on the trump suit, accounting for joker and bowers.
    # In Euchre, the Jacks and the Joker are special cards.
    class Card
      include Constants

      def initialize(rank:, suit:)
        @rank = rank == '' ? :blank : rank.to_s.upcase.to_sym
        @suit = suit == '' ? :blank : suit.to_s.upcase.to_sym
      end

      def self.for(rank:, suit:)
        case rank
        when JACK
          CardJack
        when JOKER
          CardJoker
        when ''
          CardBlank
        else
          Card
        end.new(rank: rank, suit: suit)
      end

      def rank(**_keyword_args)
        @rank
      end

      def suit(**_keyword_args)
        @suit
      end

      def to_s(trumps: nil)
        glyph = SUITS[@suit][:glyph]
        "#{rank(trumps: trumps)}#{glyph}"
      end
    end

    # The Jack can be a left bower (same color, different glyph) in which case it takes on the trump suit and the
    # rank of left bower.
    class CardJack < Card
      def rank(trumps: nil)
        return @rank if trumps.nil?

        left_bower?(trumps) ? LEFT_BOWER : @rank
      end

      def suit(trumps: nil)
        return @suit if trumps.nil?

        left_bower?(trumps) ? trumps : @suit
      end

      private

      def left_bower?(trumps)
        @suit != trumps && SUITS[@suit][:color] == SUITS[trumps][:color]
      end
    end

    # The Joker takes on the trump suit.
    class CardJoker < Card
      def suit(trumps: nil)
        trumps.nil? ? @suit : trumps
      end
    end

    # A blank card has a different string representation
    class CardBlank < Card
      def to_s
        '%%'
      end
    end
  end
end
