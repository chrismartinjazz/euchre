# frozen_string_literal: true

require_relative 'constants'
require_relative 'player'

# A computer player.
class ComputerPlayer < Player
  BID_MIN_SCORE = 6.5
  GO_ALONE_MIN_SCORE = 9.5

  def initialize(name: 'Unknown')
    super
  end

  def bid_centre_card(card:, suit:, dealer:)
    hand = @hand.dup
    hand.push(card) if dealer

    score = score_hand(suit, hand)
    announce("[score #{score}]") if DISPLAY_THINKING

    bid = score >= BID_MIN_SCORE ? suit : :pass
    going_alone = score >= GO_ALONE_MIN_SCORE && bid != :pass

    bid_text = if bid == suit && dealer
                 'I pick it up.'
               elsif bid == suit && !dealer
                 'Pick it up.'
               else
                 'Pass.'
               end
    go_alone_text = going_alone ? "I'll go alone." : ''
    announce([bid_text, go_alone_text])

    {bid: bid, going_alone: going_alone}
  end

  def bid_trumps(options:)
    scores = {}
    options.each { |suit| scores[suit] = score_hand(suit) }
    best_suit, score = scores.max_by { |_k, v| v }
    announce("[score #{score}]") if DISPLAY_THINKING

    bid = score >= BID_MIN_SCORE ? best_suit : :pass
    going_alone = score >= GO_ALONE_MIN_SCORE && bid != :pass

    bid_text = bid == :pass ? 'Pass' : "I bid #{SUITS[bid][:text]}."
    go_alone_text = going_alone ? "I'll go alone." : ''
    announce([bid_text, go_alone_text])

    {bid: bid, going_alone: going_alone}
  end

  def exchange_card(card:, trumps:)
    @hand.push(card)
    card_scores = @hand.map { |card| evaluate_card(card, trumps) }
    index = card_scores.find_index(card_scores.min)

    announce('(Picks up the centre card and exchanges it with a card from their hand)')

    @hand.delete_at(index)
  end

  def play_card(trumps:, tricks:, trick_index:)
    valid_hand_indices = find_valid_hand_indices(trumps, tricks, trick_index)
    scores = {}
    valid_hand_indices.each { |index| scores[index] = evaluate_card(@hand[index], trumps) }
    index = scores.max_by { |_k, v| v }[0]

    announce(scores) if DISPLAY_THINKING

    @hand.delete_at(index)
  end

  def choose_a_suit
    suits = SUITS.keys.reject { |suit| suit == JOKER_SUIT }
    suits[rand(suits.size)]
  end

  private

  def find_valid_hand_indices(trumps, tricks, trick_index)
    lead_suit = tricks[trick_index].lead_suit
    can_follow_suit = @hand.any? { |card| card.suit(trumps: trumps) == lead_suit }
    valid_hand_indices = []
    if can_follow_suit
      @hand.each_with_index { |card, index| valid_hand_indices.push(index) if card.suit(trumps: trumps) == lead_suit }
    else
      valid_hand_indices = [*0..(@hand.length - 1)]
    end
    valid_hand_indices
  end

  def score_hand(trumps, hand = @hand)
    hand.map { |card| evaluate_card(card, trumps) }.sum / hand.size.to_f
  end

  def evaluate_card(card, trumps)
    suit = card.suit(trumps: trumps)
    rank = card.rank(trumps: trumps)

    suit == trumps ? 6 + RANKS[:trumps].find_index(rank) : RANKS[:non_trumps].find_index(rank)
  end

  def announce(input)
    string = input.is_a?(Array) ? input.join(' ') : input
    puts "\n#{@name}: #{string}"
    sleep(THINKING_TIME)
  end
end
