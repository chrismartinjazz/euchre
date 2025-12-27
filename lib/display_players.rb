# frozen_string_literal: true

require_relative 'constants'
require_relative 'display_terminal_grid'

# Displays bidding screen
class DisplayPlayers
  def initialize
    @display_order = nil
    @col_width = DISPLAY_WIDTH / 3
  end

  def prepare(display_order:)
    @display_order = display_order
  end

  def grid(dealer:, center_card:, center_card_suit:)
    @dealer = dealer
    @center_card = center_card
    @center_card_suit = center_card_suit
    south, west, north, east = generate_player_cells
    center = generate_center_cell
    blank = DisplayTerminalGrid::Cell.new(contents: [], justified: :left)
    player_grid = DisplayTerminalGrid::Grid.new(
      grid: [
        [blank, north, blank],
        [west, center, east],
        [blank, south, blank]
      ],
      border: DisplayTerminalGrid::Border.new(vertical: '', horizontal: ' ', corner: '')
    )
    puts player_grid
    nil
  end

  private

  def generate_player_cells
    south, west, north, east = @display_order.each_with_object([]) do |player, array|
      array.push(DisplayTerminalGrid::Cell.new(contents: [player_name(player), hand_text(player)]))
    end
    south.update(justified: :center)
    west.update(justified: :left)
    north.update(justified: :center)
    east.update(justified: :right)
    [south, west, north, east]
  end

  def generate_center_cell
    center_suit_text = @center_card.rank == JOKER ? "#{SUITS[@center_card_suit][:glyph]} |" : '|'
    center_text = "| #{@center_card} #{center_suit_text}"
    center_box = "+#{'-' * [(clean(center_text).length - 2), 0].max}+"
    DisplayTerminalGrid::Cell.new(contents: [center_box, center_text, center_box], justified: :center)
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
end
