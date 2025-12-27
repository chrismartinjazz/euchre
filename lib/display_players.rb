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

  def grid(dealer:, centre_card:, centre_card_suit:)
    @dealer = dealer
    @centre_card = centre_card
    @centre_card_suit = centre_card_suit
    south, west, north, east = generate_player_cells
    centre = generate_centre_cell
    blank = DisplayTerminalGrid::Cell.new(contents: [], justified: :left)
    player_grid = DisplayTerminalGrid::Grid.new(
      grid: [
        [blank, north, blank],
        [west, centre, east],
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

  def generate_centre_cell
    centre_suit_text = @centre_card.rank == JOKER ? "#{SUITS[@centre_card_suit][:glyph]} |" : '|'
    centre_text = "| #{@centre_card} #{centre_suit_text}"
    centre_box = "+#{'-' * [(clean(centre_text).length - 2), 0].max}+"
    DisplayTerminalGrid::Cell.new(contents: [centre_box, centre_text, centre_box], justified: :center)
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
