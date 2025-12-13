# frozen_string_literal: true

require_relative 'constants'
require_relative 'trick'

# Manages the playing of successive tricks, updates player order based on the winner of previous trick,
# tracks the score, the winning team and points scored.
class TrickManager
  HAND_SIZE = 5
  TRICK_SCORES_TO_POINTS = [2, 2, 2, 1, 1, 2].freeze
  BIDDERS_MUST_WIN_N_TRICKS = (HAND_SIZE / 2) + 1
  GOING_ALONE_BONUS = 2
  MIN_COL_WIDTH = 7

  attr_reader :winner, :points

  def initialize(display:)
    @display = display
  end

  def play_hand(trumps:, going_alone:, bidders:, defenders:, player_order:)
    init_hand(trumps: trumps, going_alone: going_alone, bidders: bidders, defenders: defenders, player_order: player_order)
    HAND_SIZE.times do |index|
      play_trick(index)
      @trick_score += 1 if bidders_win_trick?(index)
      @display.message(message: "#{@tricks[index].winner} wins the trick.", confirmation: true)
      rotate_player_order_to_start_with(@tricks[index].winner)
    end

    @winner = bidders_win_hand? ? @bidders : @defenders
    @points = score_hand
  end

  private

  def init_hand(trumps:, going_alone:, bidders:, defenders:, player_order:)
    @trumps = trumps
    @going_alone = going_alone
    @bidders = bidders
    @defenders = defenders
    @player_order = player_order
    @dealer = player_order[-1]
    @tricks = Array.new(HAND_SIZE) { Trick.new(trumps: @trumps, player_count: @player_order.length) }
    @trick_score = 0
    @winner = nil
    @points = nil
  end

  def play_trick(index)
    @player_order.each do |player|
      update_display
      card = player.play_card(trumps: @trumps, tricks: @tricks, trick_index: index)
      @tricks[index].add(player: player, card: card)
    end
    update_display
  end

  def update_display
    @display.clear_screen
    @display.score
    @display.players(dealer: @dealer)
    @display.tricks(players: @player_order, trumps: @trumps, tricks: @tricks, bidders: @bidders)
  end

  def bidders_win_trick?(index)
    @bidders.include?(@tricks[index].winner)
  end

  def rotate_player_order_to_start_with(starting_player)
    @player_order.rotate!(@player_order.find_index(starting_player))
  end

  def bidders_win_hand?
    @trick_score >= BIDDERS_MUST_WIN_N_TRICKS
  end

  def score_hand
    base_score + going_alone_bonus
  end

  def base_score
    TRICK_SCORES_TO_POINTS[@trick_score]
  end

  def going_alone_bonus
    @trick_score == HAND_SIZE && @going_alone ? GOING_ALONE_BONUS : 0
  end
end
