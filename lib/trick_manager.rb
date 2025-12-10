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

  def initialize(trumps:, going_alone:, bidding_team:, player_order:)
    @trumps = trumps
    @going_alone = going_alone
    @bidding_team = bidding_team
    @player_order = player_order

    @display_order = player_order.dup
    @tricks = Array.new(HAND_SIZE) { Trick.new(trumps: @trumps, player_count: @player_order.length) }
    @trick_score = 0
    @winner = nil
    @points = nil
  end

  def play_hand
    HAND_SIZE.times do |index|
      play_trick(index)
      @trick_score += 1 if bidding_team_wins_trick?(index)
      rotate_player_order_to_start_with(@tricks[index].winner)
    end

    @winner = bidding_team_wins_hand? ? 'bidders' : 'defenders'
    @points = score_hand
  end

  private

  def play_trick(index)
    @player_order.each do |player|
      display_header
      display_tricks
      card = player.play_card(trumps: @trumps, tricks: @tricks, trick_index: index)
      @tricks[index].add(player: player, card: card)
    end
    display_header
    display_tricks
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

  def display_header
    bidding_team_string = @bidding_team.map(&:to_s).join(' ')
    puts "Bidders: #{bidding_team_string} ... Tricks: #{@trick_score}"
  end

  def display_tricks
    col_width = calculate_col_width
    header = generate_trick_table_header(col_width)
    table = generate_trick_table(col_width)

    puts header
    puts table
  end

  def calculate_col_width
    max_player_name_length = @display_order.max_by { |player| player.to_s.length }.to_s.length
    [max_player_name_length + 3, MIN_COL_WIDTH].max
  end

  def generate_trick_table_header(col_width)
    header = "#{SUITS[@trumps][:glyph]}    "
    @display_order.each do |player|
      header += player.name
      header += ' ' * (col_width - player.name.length)
    end
    header += 'Winner'
    header
  end

  def generate_trick_table(col_width)
    table = ''
    @tricks.each_with_index do |trick, index|
      table += generate_trick_row(trick, index, col_width)
    end
    table
  end

  def generate_trick_row(trick, index, col_width)
    number = index + 1
    lead_suit_glyph = trick.lead_suit.nil? ? ' ' : SUITS[trick.lead_suit][:glyph]
    cards = generate_cards_for_trick_row(trick, col_width)
    winner = trick.winner ? trick.winner.to_s : ''

    "#{number}:#{lead_suit_glyph}| #{cards}#{winner}\n"
  end

  def generate_cards_for_trick_row(trick, col_width)
    cards = ''
    @display_order.each do |player|
      player_card = trick.card(player: player).nil? ? '  ' : trick.card(player: player).to_s(trumps: @trumps)
      winning_card_indication = trick.winning_play && trick.winning_play[:card] == trick.card(player: player) ? ' *' : '  '
      padding = ' ' * (col_width - 6)

      cards += "#{player_card}#{winning_card_indication}#{padding}| "
    end
    cards
  end
end
