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
    bidding_round_one
    return @bid unless @bid == :pass

    @display.message(message: "#{@dealer}: I turn it down.", confirmation: true)
    update_display(show_centre_card: false)
    bidding_round_two([CLUBS, DIAMONDS, HEARTS, SPADES] - [@centre_card_suit])
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

  def bidding_round_one
    @player_order.each do |player|
      response = player.decide_bid(
        options: [@centre_card_suit], card: @centre_card, dealer: dealer_relationship_to(player)
      )
      next if response[:bid] == :pass

      @dealer.exchange_card!(card: @centre_card, trumps: response[:bid])
      handle_response(response, player)
      return nil
    end
    @bid = :pass
  end

  def dealer_relationship_to(player)
    if @dealer == player
      :self
    elsif (@team1.include?(@dealer) && @team1.include?(player)) || (@team2.include?(@dealer) && @team2.include?(player))
      :partner
    end
  end

  def bidding_round_two(available_trumps)
    @player_order.each do |player|
      response = player.decide_bid(options: available_trumps)
      next if response[:bid] == :pass

      handle_response(response, player)
      return nil
    end
    @bid = :pass
  end

  def handle_response(response, player)
    @bid = response[:bid]
    @going_alone = response[:going_alone]

    determine_bidders_and_defenders(player)
    update_player_order(player)
    nil
  end

  def determine_bidders_and_defenders(player)
    if @team1.include?(player)
      @bidders = @team1
      @defenders = @team2
    else
      @bidders = @team2
      @defenders = @team1
    end
  end

  def update_player_order(player)
    trick_players = @going_alone ? [player] + @defenders : @bidders + @defenders
    @player_order = @player_order.intersection(trick_players)
  end
end
