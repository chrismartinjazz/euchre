# frozen_string_literal: true

require_relative '../constants'
require_relative 'computer_player_helpers'

module Euchre
  module Players
    # Handles the bidding decisions of the ComputerPlayer object.
    # Evaluates hand and options and returns {bid: going_alone:}
    # Chooses a card to exchange: adds the given card to the hand, deletes a card from the hand, returns the deleted card)
    class ComputerPlayerBidding
      include Constants
      include ComputerPlayerHelpers

      attr_writer :name

      CARD_EVALUATION_FUNCTION = ->(card_score) { card_score**1.05 }
      BID_SCORE = 6.5
      GO_ALONE_SCORE = 9.5

      def initialize(name: 'Unknown')
        @name = name
      end

      def decide_bid(options:, hand:, card: nil, dealer: nil)
        my_hand = hand.dup
        handle_center_card(my_hand, options[0], card, dealer) if card && %i[partner self].include?(dealer)
        suit, score = best_option_and_score(my_hand, options)
        announce(@name, score) if DISPLAY_THINKING
        bid, going_alone = evaluate_bid(suit, score)
        announce(@name, bid_text(bid, going_alone, dealer), confirmation: bid != :pass)
        { bid: bid, going_alone: going_alone }
      end

      def exchange_card!(card:, trumps:, hand:)
        hand.push(card)
        off_trump_single = find_worst_off_trump_single(hand, trumps) # ?J, JC, JS, AC, *AS*, KC
        discard_index = off_trump_single ? hand.find_index(off_trump_single) : worst_card_index(hand, trumps)
        hand.delete_at(discard_index)
      end

      def choose_a_suit
        suits = [CLUBS, DIAMONDS, HEARTS, SPADES]
        suit = suits[rand(4)]
        announce(@name, "I choose #{SUITS[suit][:text]}", confirmation: true)
        suit
      end

      private

      def handle_center_card(my_hand, suit, card, dealer)
        case dealer
        when :partner
          my_hand.push(card)
        when :self
          exchange_card!(hand: my_hand, card: card, trumps: suit)
        end
      end

      def find_worst_off_trump_single(hand, trumps)
        return nil if count_trumps(hand, trumps) < 2

        cards = off_trump_singles(hand, trumps)
        cards.length.positive? ? cards[worst_card_index(cards, trumps)] : nil
      end

      def count_trumps(hand, trumps)
        hand.select { |card| card.suit == trumps }.length
      end

      def off_trump_singles(hand, trumps)
        count_by_suit = hand.group_by { |card| card.suit(trumps: trumps) }.transform_values(&:size)
        held_off_trump_suits = count_by_suit.select do |suit, count|
          ([CLUBS, DIAMONDS, HEARTS, SPADES] - [trumps]).include?(suit) && count == 1
        end.keys
        hand.select { |card| held_off_trump_suits.include?(card.suit(trumps: trumps)) && card.rank != ACE }
      end

      def worst_card_index(my_hand, trumps)
        scores = card_scores(my_hand, trumps)
        scores.find_index(scores.min)
      end

      def card_scores(my_hand, trumps)
        my_hand.map { |card| evaluate_card(card, trumps) }
      end

      def average_card_score(my_hand, trumps)
        my_hand.map { |card| evaluate_card(card, trumps) }.sum / my_hand.size.to_f
      end

      def evaluate_card(card, trumps)
        return 0 if card.nil?

        suit = card.suit(trumps: trumps)
        rank = card.rank(trumps: trumps)

        score = suit == trumps ? 6 + RANKS[:trumps].find_index(rank) : RANKS[:non_trumps].find_index(rank)
        CARD_EVALUATION_FUNCTION.call(score)
      end

      def best_option_and_score(my_hand, my_options)
        my_options
          .each_with_object({}) { |suit, object| object[suit] = average_card_score(my_hand, suit) }
          .max_by { |_k, v| v }
      end

      def evaluate_bid(suit, score)
        bid = score >= BID_SCORE ? suit : :pass
        going_alone = score >= GO_ALONE_SCORE && bid != :pass
        [bid, going_alone]
      end

      def bid_text(bid, going_alone, dealer)
        return 'Pass' if bid == :pass

        text_for_bid = case dealer
                        when :self
                          'I pick it up'
                        when :partner
                          'Pick it up, partner'
                        else
                          'Pick it up'
                        end
        "#{text_for_bid} #{"I'll go alone." if going_alone}".strip
      end
    end
  end
end
