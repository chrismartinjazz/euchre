# frozen_string_literal: true

require_relative 'trick'
require_relative 'suits'

# Manages the playing of successive tricks, updates player order based on the winner of previous trick,
# tracks the score, and reports the winning team and points scored.
class TrickManager
  HAND_SIZE = 5
  TRICK_SCORES_TO_POINTS = [4, 2, 2, 1, 2].freeze
  BIDDERS_MUST_WIN_N_TRICKS = (HAND_SIZE / 2) + 1
  SWEEP_BONUS = 2

  def initialize(trumps = nil, tricks = nil)
    @trumps = trumps
    @tricks = tricks.nil? ? Array.new(HAND_SIZE) { Trick.new(@trumps) } : tricks
  end

  def play_hand(going_alone, bidding_team, defending_team, player_order, player_teams)
    @going_alone = going_alone
    @bidding_team = bidding_team
    @defending_team = defending_team
    @player_order = player_order
    @player_teams = player_teams
    @display_order = player_order # Always display trick plays in same order

    @trick_score = 0

    display_header

    HAND_SIZE.times do |index|
      play_trick(index)
      @trick_score += 1 if bidding_team_wins_trick?(index)
      @player_order = player_order_starting_with(@tricks[index].winner)
    end

    {
      winners: bidding_team_wins_hand?(@trick_score) ? @bidding_team : @non_bidding_team,
      points: score_hand(@trick_score)
    }
  end

  def play_trick(index)
    @player_order.each do |player|
      display_tricks
      card = player.play_card(@trumps, @tricks, index)
      @tricks[index].add(player, card)
    end
  end

  def bidding_team_wins_trick?(index)
    @player_teams[@tricks[index].winner] == @bidding_team
  end

  def player_order_starting_with(starting_player)
    order = @player_order.dup
    order.find_index(starting_player).times { order.push(order.unshift) }
    order
  end

  def bidding_team_wins_hand?
    @trick_score >= WINNERS_MUST_WIN_N_TRICKS
  end

  def score_hand
    base_score = TRICK_SCORES_TO_POINTS[@trick_score]
    bonus = sweep_bonus? ? SWEEP_BONUS : 0
    base_score + bonus
  end

  def sweep_bonus?
    (@trick_score.zero? || @trick_score == HAND_SIZE) && @going_alone
  end

  def display_header
    my_trumps = "Trumps: #{SUITS[@trumps][:glyph]}"
    my_bidders = "Bidders: #{@bidding_team}"
    my_defenders = "Defenders: #{@defending_team}"
    puts "#{my_trumps} #{my_bidders} #{my_defenders}"
  end

  def display_tricks
    # Set the width of the column to be the maximum player name length
    max_player_name_length = @display_order.max_by { |player| player.to_s.length }.to_s.length
    col_width = [max_player_name_length + 2, 5].max

    # Add the header with player names to the display string
    #      North  East   South  West   Winner
    output = '     '
    output += @display_order.map { |player| player.name += ' ' * (col_width - player.name.length) }
    output += 'Winner'

    @tricks.each_with_index do |trick, index|
      trick_string = "#{i + 1}: | "
      trick_string += @player_order.each { |player| trick.card(player) || '  ' }.join('| ')
      trick_string += trick.winner
      output += trick_string
      output += "\n"
    end
    puts output
    #      North  East   South  West   Winner
    # 1: | AD   | KD   | KS   | 9C   | West
    # 2: |      |      |      |      |
  end
end
