# frozen_string_literal: true

require_relative 'constants'

# Handles displaying the tricks table
class DisplayTricks
  STUB_WIDTH = 4
  MIN_COL_WIDTH = 7

  def prepare(context:)
    @col_width = calculate_col_width(context)
  end

  def table(context:)
    table = generate_trick_table(context)
    puts table
  end

  private

  def calculate_col_width(context)
    max_player_name_length = context.display_order.max_by { |player| player.to_s.length }.to_s.length
    [max_player_name_length + 3, MIN_COL_WIDTH].max
  end

  def generate_trick_table(context)
    table = [generate_trick_table_header(context)]
    context.tricks.each_with_index do |trick, index|
      table.push(generate_trick_table_row(trick, index, context))
    end
    table
  end

  def generate_trick_table_header(context)
    cells = [SUITS[context.bid.trumps][:glyph].to_s]
    context.display_order.each do |player|
      cells.push(context.bid.bidders.include?(player) ? "#{player.name}*" : player.name)
    end
    cells.push('Winner')
    generate_row(cells, ' ')
  end

  def generate_trick_table_row(trick, index, context)
    number = index + 1
    lead_suit_glyph = trick.lead_suit.nil? ? ' ' : SUITS[trick.lead_suit][:glyph]
    cells = ["#{number}:#{lead_suit_glyph}"]
    generate_card_cells(cells, trick, context)
    cells.push(trick.winner ? trick.winner.to_s : '')
    generate_row(cells, '|')
  end

  def generate_card_cells(cells, trick, context)
    context.display_order.each do |player|
      card = trick.card(player: player).nil? ? '  ' : trick.card(player: player).to_s(trumps: context.bid.trumps)
      winning = trick.winning_play[:card] && trick.winning_play[:card] == trick.card(player: player) ? ' *' : '  '
      cells.push("#{card}#{winning}")
    end
  end

  def generate_row(cells, separator)
    widths = [STUB_WIDTH].concat(Array.new(cells.length - 1) { @col_width })
    formatted_cells = []
    cells.each_with_index do |cell, index|
      cell_text = " #{cell}"
      padding = ' ' * [(widths[index] - cell_text.gsub(ANSI_ESCAPE, '').length), 0].max
      formatted_cells.push("#{cell_text}#{padding}")
    end
    "#{formatted_cells.join(separator)}#{separator}"
  end
end
