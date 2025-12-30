# frozen_string_literal: true

require_relative 'constants'
require_relative 'trick'
require_relative 'result'

# Manages the playing of successive tricks, updates player order based on the winner of previous trick,
# tracks the score, the winning team and points scored.
class TrickManager
  HAND_SIZE = 5
  GOING_ALONE_BONUS = 2

  def play_hand(context:, display:, tricks: nil)
    initialize_hand(context, tricks)
    @number_of_tricks.times do |index|
      play_trick(index, context, display)
      rotate_player_order_to_start_with_trick_winner(index, context)
    end

    context.result = Result.new(
      winners: bidders_win_hand? ? context.bid.bidders : context.bid.defenders,
      points: score_hand(context)
    )
    context
  end

  private

  def initialize_hand(context, tricks)
    tricks ||= Array.new(HAND_SIZE) do
      Trick.new(
        trumps: context.bid.trumps,
        player_count: context.player_order.length
      )
    end
    context.tricks = tricks
    @number_of_tricks = context.tricks.size
    @tricks_won_by_bidders = 0
  end

  def play_trick(index, context, display)
    context.player_order.each do |player|
      update_display(context, display)
      card = player.play_card(trumps: context.bid.trumps, tricks: context.tricks, trick_index: index)
      context.tricks[index].add(player: player, card: card)
    end
    update_display(context, display)
    @tricks_won_by_bidders += 1 if bidders_win_trick?(index, context)
    display.message(message: "#{context.tricks[index].winner} wins the trick.", confirmation: true)
  end

  def update_display(context, display)
    display.clear_screen
    display.score(context: context)
    display.players(context: context)
    display.tricks(context: context)
  end

  def bidders_win_trick?(index, context)
    context.bid.bidders.include?(context.tricks[index].winner)
  end

  def rotate_player_order_to_start_with_trick_winner(index, context)
    winner = context.tricks[index].winner
    context.player_order.rotate!(context.player_order.find_index(winner))
  end

  def score_hand(context)
    base_score + going_alone_bonus(context)
  end

  def base_score
    !bidders_win_hand? || bidders_win_all_tricks? ? 2 : 1
  end

  def going_alone_bonus(context)
    bidders_win_all_tricks? && context.bid.going_alone ? GOING_ALONE_BONUS : 0
  end

  def bidders_win_hand?
    @tricks_won_by_bidders >= (@number_of_tricks / 2) + 1
  end

  def bidders_win_all_tricks?
    @tricks_won_by_bidders == @number_of_tricks
  end
end
