# frozen_string_literal: true

require_relative 'constants'

# Manages bidding
class BiddingManager
  attr_reader :player_order, :bid, :going_alone, :bidders, :defenders

  def initialize(display:, team1:, team2:)
    @display = display
    @team1 = team1
    @team2 = team2
  end

  def handle_bidding(player_order:, centre_card:, centre_card_suit:)
    init_bidding(player_order: player_order, centre_card: centre_card, centre_card_suit: centre_card_suit)
    update_display(show_centre_card: true)
    bid_centre_card
    return @bid unless @bid.nil?

    @display.message(message: "#{@dealer}: I turn it down.", confirmation: true)
    update_display(show_centre_card: false)
    bid_trumps([CLUBS, DIAMONDS, HEARTS, SPADES] - [@centre_card_suit])
    return @bid unless @bid.nil?

    nil
  end

  private

  def init_bidding(player_order:, centre_card:, centre_card_suit:)
    @player_order = player_order
    @dealer = player_order[-1]
    @centre_card = centre_card
    @centre_card_suit = centre_card_suit
    @bid = nil
  end

  def update_display(show_centre_card:)
    @display.clear_screen
    @display.score
    if show_centre_card
      @display.players(dealer: @dealer, centre_card: @centre_card, centre_card_suit: @centre_card_suit)
    else
      @display.players(dealer: @dealer)
    end
  end

  def bid_centre_card
    @player_order.each do |player|
      response = player.bid_centre_card(card: @centre_card, suit: @centre_card_suit, dealer: player == @dealer)
      next if response[:bid] == :pass

      @dealer.exchange_card(card: @centre_card, trumps: response[:bid])
      handle_response(response)
      break
    end
  end

  def bid_trumps(available_trumps)
    @player_order.each do |player|
      response = player.bid_trumps(options: available_trumps)
      next if response[:bid] == :pass

      handle_response(response)
      break
    end
  end

  def handle_response(response)
    @bid = response[:bid]
    @going_alone = response[:going_alone]
    @bidders = if @going_alone
                 [response[:player]]
               elsif @team1.include?(response[:player])
                 @team1
               else
                 @team2
               end
    @defenders = @team1.include?(@bidders[0]) ? @team2 : @team1
    @player_order.filter! { |player| (@bidders + @defenders).include?(player) }
    nil
  end
end
