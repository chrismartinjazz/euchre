# frozen_string_literal: true

require_relative 'constants'

Cell = Struct.new(:contents, :justified)

# Displays bidding screen
class DisplayPlayers
  def initialize(players:)
    @players = players
    @col_width = 20
  end

  def players(dealer:, centre_card:, centre_card_suit:)
    @dealer = dealer
    @centre_card = centre_card
    @centre_card_suit = centre_card_suit
    south, west, north, east = generate_player_cells
    centre = generate_centre_cell
    blank = Cell.new([], 'left')
    grid = [
      [blank, north, blank],
      [west, centre, east],
      [blank, south, blank]
    ]
    heights = row_heights(grid)
    print_grid(grid, heights)
    nil
  end

  private

  def generate_player_cells
    south, west, north, east = @players.each_with_object([]) do |player, array|
      array.push(Cell.new([player_name(player), hand_text(player)], ''))
    end
    south.justified = 'centre'
    west.justified = 'left'
    north.justified = 'centre'
    east.justified = 'right'
    [south, west, north, east]
  end

  def generate_centre_cell
    centre_suit_text = @centre_card.rank == JOKER ? "#{SUITS[@centre_card_suit][:glyph]} |" : '|'
    centre_text = "| #{@centre_card} #{centre_suit_text}"
    centre_box = "+#{'-' * [(clean(centre_text).length - 2), 0].max}+"
    Cell.new([centre_box, centre_text, centre_box], 'centre')
  end

  def player_name(player)
    player == @dealer ? "#{player.to_s.upcase} *DEALER*" : player.to_s
  end

  def hand_text(player, separator = ' |', card_back = ' %')
    hand = player.is_a?(HumanPlayer) ? player.hand : Array.new(player.hand.length) { card_back }
    hand.join(separator)
  end

  def clean(text)
    text.to_s.gsub(ANSI_ESCAPE, '')
  end

  def print_grid(grid, heights)
    grid.each_with_index do |grid_row, grid_row_index|
      (heights[grid_row_index] + 1).times do |cell_row_index|
        row_parts = []
        grid_row.each do |cell|
          row_parts.push(justify(cell.contents[cell_row_index], cell.justified))
        end
        puts row_parts.join
      end
    end
  end

  def justify(text, justified)
    my_text = text.to_s
    case justified
    when 'centre'
      centre_justify(my_text)
    when 'right'
      right_justify(my_text)
    else
      left_justify(my_text)
    end
  end

  def left_justify(text)
    my_text, my_col_width, my_length = justify_parameters(text)
    space_after = ' ' * [(my_col_width - my_text.length), 0].max
    safe_join([my_text, space_after], my_col_width)
  end

  def centre_justify(text)
    my_text, my_col_width, my_length = justify_parameters(text)
    space_before = ' ' * [((-0.5 * my_length) + (my_col_width / 2.0)).floor, 0].max
    space_after = ' ' * [((-0.5 * my_length) + (my_col_width / 2.0)).ceil, 0].max
    safe_join([space_before, my_text, space_after], my_col_width)
  end

  def right_justify(text)
    my_text, my_col_width, my_length = justify_parameters(text)
    space_before = ' ' * [(my_col_width - my_text.length), 0].max
    safe_join([space_before, my_text], my_col_width)
  end

  def justify_parameters(text)
    my_text = text.to_s
    my_col_width = compensate_col_width_for_ansi_escape(my_text)
    my_length = my_text.length
    [my_text, my_col_width, my_length]
  end

  def safe_join(array, max_width)
    array.join[0..[(max_width - 1), 0].max]
  end

  def compensate_col_width_for_ansi_escape(text)
    @col_width + text.to_s.scan(ANSI_ESCAPE).join.length
  end

  def row_heights(grid)
    grid.each_with_object([]) do |row, array|
      array.push(row.max_by { |cell| cell.contents.size }.contents.size)
    end
  end
end
