# frozen_string_literal: true

require_relative 'constants'
require_relative 'bid'

# Manages bidding
class BiddingManager
  def initialize
    @blank_card = Card.for(rank: '', suit: '')
  end

  def handle_bidding(context:, display:)
    context.bid = Bid.new
    center_card_suit = context.center_card_suit

    update_display(context, display)
    bidding_round_one(context)
    return context unless context.bid.pass

    display.message(message: "#{context.dealer}: I turn it down.", confirmation: true)
    update_display(context, display)
    bidding_round_two([CLUBS, DIAMONDS, HEARTS, SPADES] - [center_card_suit], context)
    context
  end

  private

  def update_display(context, display)
    display.clear_screen
    display.score(context: context)
    display.players(context: context)
  end

  def bidding_round_one(context)
    context.player_order.each do |player|
      response = player.decide_bid(
        options: [context.center_card_suit], card: context.center_card, dealer: dealer_relationship_to(player, context)
      )
      next if response[:bid] == :pass

      context.dealer.exchange_card!(card: context.center_card, trumps: response[:bid])
      handle_response(response, player, context)

      context.center_card = @blank_card
      context.center_card_suit = @blank_card.suit
      return nil
    end
    context.bid.pass = true
  end

  def dealer_relationship_to(player, context)
    if context.dealer == player
      :self
    elsif (context.players.team1.include?(context.dealer) && context.players.team1.include?(player)) ||
          (context.players.team2.include?(context.dealer) && context.players.team2.include?(player))
      :partner
    else
      :opposition
    end
  end

  def bidding_round_two(available_trumps, context)
    context.player_order.each do |player|
      response = player.decide_bid(options: available_trumps)
      next if response[:bid] == :pass

      handle_response(response, player, context)
      return nil
    end
    context.bid.pass = true
  end

  def handle_response(response, player, context)
    context.bid.pass = false
    context.bid.bidder = player
    context.bid.trumps = response[:bid]
    context.bid.going_alone = response[:going_alone]

    determine_bidders_and_defenders(player, context)
    update_player_order(player, context)
    nil
  end

  def determine_bidders_and_defenders(player, context)
    if context.players.team1.include?(player)
      context.bid.bidders = context.players.team1
      context.bid.defenders = context.players.team2
    else
      context.bid.bidders = context.players.team2
      context.bid.defenders = context.players.team1
    end
  end

  def update_player_order(player, context)
    trick_players = if context.bid.going_alone
                      [player] + context.bid.defenders
                    else
                      context.bid.bidders + context.bid.defenders
                    end
    context.player_order = context.player_order.intersection(trick_players)
  end
end
