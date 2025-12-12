# frozen_string_literal: true

require_relative 'constants'
require_relative 'trick'

# Manages the playing of successive tricks, updates player order based on the winner of previous trick,
# tracks the score, and reports the winning team ('bidders' or 'defenders') and points scored.
class TrickManager
  HAND_SIZE = 5
  TRICK_SCORES_TO_POINTS = [2, 2, 2, 1, 1, 2].freeze
  BIDDERS_MUST_WIN_N_TRICKS = (HAND_SIZE / 2) + 1
  GOING_ALONE_BONUS = 2
  MIN_COL_WIDTH = 7

  attr_reader :winner, :points

  def initialize(display:, trumps:, going_alone:, bidding_team:, player_order:)
    @display = display
    @trumps = trumps
    @going_alone = going_alone
    @bidding_team = bidding_team
    @player_order = player_order
    @dealer = player_order[-1]

    @tricks = Array.new(HAND_SIZE) { Trick.new(trumps: @trumps, player_count: @player_order.length) }
    @trick_score = 0
    @winner = nil
    @points = nil
  end

  def play_hand
    HAND_SIZE.times do |index|
      play_trick(index)
      @trick_score += 1 if bidding_team_wins_trick?(index)
      @display.message(message: "#{@tricks[index].winner} wins the trick.", confirmation: true)
      rotate_player_order_to_start_with(@tricks[index].winner)
    end

    @winner = bidding_team_wins_hand? ? 'bidders' : 'defenders'
    @points = score_hand
  end

  private

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
    @display.tricks(trumps: @trumps, tricks: @tricks, bidding_team: @bidding_team)
  end

  def bidding_team_wins_trick?(index)
    @bidding_team.include?(@tricks[index].winner)
  end

  def rotate_player_order_to_start_with(starting_player)
    @player_order.rotate!(@player_order.find_index(starting_player))
  end

  def bidding_team_wins_hand?
    @trick_score >= BIDDERS_MUST_WIN_N_TRICKS
  end

  def score_hand
    base_score = TRICK_SCORES_TO_POINTS[@trick_score]
    bonus = going_alone_bonus ? GOING_ALONG_BONUS : 0
    base_score + bonus
  end

  def going_alone_bonus
    @trick_score == HAND_SIZE && @going_alone
  end
end
