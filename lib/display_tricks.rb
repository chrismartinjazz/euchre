# frozen_string_literal: true

require_relative 'constants'

# Handles displaying the tricks table
class DisplayTricks
  def initialize
    @display_order = nil
    @stub_width = 4
    @min_col_width = 7
  end

  def prepare(display_order:)
    @display_order = display_order
    @col_width = calculate_col_width
  end

  def table(trumps:, tricks:, bidders:)
    @trumps = trumps
    @tricks = tricks
    @bidders = bidders

    table = generate_trick_table
    puts table
  end

  private

  def calculate_col_width
    max_player_name_length = @display_order.max_by { |player| player.to_s.length }.to_s.length
    [max_player_name_length + 3, @min_col_width].max
  end

  def generate_trick_table
    table = [generate_trick_table_header]
    @tricks.each_with_index do |trick, index|
      table.push(generate_trick_table_row(trick, index))
    end
    table
  end

  def generate_trick_table_header
    cells = [SUITS[@trumps][:glyph].to_s]
    @display_order.each do |player|
      cells.push(@bidders.include?(player) ? "#{player.name}*" : player.name)
    end
    cells.push('Winner')
    generate_row(cells, ' ')
  end

  def generate_trick_table_row(trick, index)
    number = index + 1
    lead_suit_glyph = trick.lead_suit.nil? ? ' ' : SUITS[trick.lead_suit][:glyph]
    cells = ["#{number}:#{lead_suit_glyph}"]
    @display_order.each do |player|
      card = trick.card(player: player).nil? ? '  ' : trick.card(player: player).to_s(trumps: @trumps)
      winning = trick.winning_play && trick.winning_play[:card] == trick.card(player: player) ? ' *' : '  '
      cells.push("#{card}#{winning}")
    end
    cells.push(trick.winner ? trick.winner.to_s : '')
    generate_row(cells, '|')
  end

  def generate_row(cells, separator)
    widths = [@stub_width].concat(Array.new(cells.length - 1) { @col_width })
    formatted_cells = []
    cells.each_with_index do |cell, index|
      cell_text = " #{cell}"
      padding = ' ' * [(widths[index] - cell_text.gsub(ANSI_ESCAPE, '').length), 0].max
      formatted_cells.push("#{cell_text}#{padding}")
    end
    "#{formatted_cells.join(separator)}#{separator}"
  end
end
