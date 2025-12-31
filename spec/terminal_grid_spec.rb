# frozen_string_literal: true

require 'euchre'
require 'helpers'

module Euchre
  RSpec.describe TerminalGrid::Grid do
    let(:grid) { TerminalGrid::Grid.new }

    describe '#puts' do
      it 'shows the table with borders' do
        silence do
          a1 = TerminalGrid::Cell.new(contents: ['Left justified.', 'Another line of text'], justified: :left)
          a2 = TerminalGrid::Cell.new(contents: ['Right justified.', 'More text'], justified: :right)
          a3 = TerminalGrid::Cell.new(contents: ['Centre justified.', 'more', 'and more!'], justified: :center)
          grid.update(grid: [[a1, a2, a3], [a2, a1]])
          puts grid
        end
      end

      it 'handles ansi escape (colorization of text)' do
        silence do
          puts
          a1 = TerminalGrid::Cell.new(contents: ["\e[31m♥\e[0m Heart!", "Heart! \e[31m♥\e[0m"])
          grid.update(grid: [[a1]])
          puts grid
        end
      end

      it 'handles cells of varying widths: using cell widths, flexing remaining cell widths to fill up space, allowing short rows, truncating long rows, handling all border intersections' do
        silence do
          puts
          a1 = TerminalGrid::Cell.new(contents: ['Cell', 'A1'], width: 30)
          a2 = TerminalGrid::Cell.new(contents: ['Cell', 'A2'], width: 35)
          a3 = TerminalGrid::Cell.new(contents: ['Cell', 'A3'], width: 40)
          b1 = TerminalGrid::Cell.new(contents: ['Cell', 'B1'], width: 15)
          b2 = TerminalGrid::Cell.new(contents: ['Cell', 'B2'], width: 18)
          b3 = TerminalGrid::Cell.new(contents: ['Cell', 'B3'])
          c1 = TerminalGrid::Cell.new(contents: ['Cell', 'C1'], width: 5)
          c2 = TerminalGrid::Cell.new(contents: ['Cell', 'C2'], width: 5)
          c3 = TerminalGrid::Cell.new(contents: ['Cell', 'C3'], width: 5)
          d1 = TerminalGrid::Cell.new(contents: ['Cell', 'D1'], width: 50)
          d2 = TerminalGrid::Cell.new(contents: ['Cell', 'D2'], width: 50)
          d3 = TerminalGrid::Cell.new(contents: ['Cell', 'D3'], width: 50)


          grid.update(grid: [
            [a1, a2, a3],
            [b1, b2, b3],
            [c1, c2, c3],
            [d1, d2, d3]
          ])
          puts grid
        end
      end

      it 'works with a redefined border' do
        silence do
          puts
          border = TerminalGrid::Border.new(vertical: '│', horizontal: '─', corner: '┼')
          a1 = TerminalGrid::Cell.new(contents: ['Left justified.', 'Another line of text'], justified: :left)
          a2 = TerminalGrid::Cell.new(contents: ['Right justified.', 'More text'], justified: :right)
          a3 = TerminalGrid::Cell.new(contents: ['Centre justified.', 'more', 'and more!'], justified: :center)
          grid.update(grid: [[a1, a2, a3], [a2, a1]], border: border)
          puts grid
        end
      end

      it 'works with no border' do
        silence do
          puts
          border = TerminalGrid::Border.new(vertical: '', horizontal: '', corner: '')
          a1 = TerminalGrid::Cell.new(contents: ['Left justified.', 'Another line of text'], justified: :left)
          a2 = TerminalGrid::Cell.new(contents: ['Right justified.', 'More text'], justified: :right)
          a3 = TerminalGrid::Cell.new(contents: ['Centre justified.', 'more', 'and more!'], justified: :center)
          grid.update(grid: [[a1, a2, a3], [a2, a1]], border: border)
          puts grid
        end
      end

      it 'works with a blank line between each row' do
        silence do
          puts
          border = TerminalGrid::Border.new(vertical: '', horizontal: ' ', corner: '')
          a1 = TerminalGrid::Cell.new(contents: ['Left justified.', 'Another line of text'], justified: :left)
          a2 = TerminalGrid::Cell.new(contents: ['Right justified.', 'More text'], justified: :right)
          a3 = TerminalGrid::Cell.new(contents: ['Centre justified.', 'more', 'and more!'], justified: :center)
          grid.update(grid: [[a1, a2, a3], [a2, a1]], border: border)
          puts grid
        end
      end
    end

    describe '#update_cell' do
      it 'allows updating a cells contents' do
        silence do
          puts
          a1 = TerminalGrid::Cell.new(contents: ['Left justified.', 'Another line of text'], justified: :left)
          a2 = TerminalGrid::Cell.new(contents: ['Left justified.'], justified: :left)
          b1 = TerminalGrid::Cell.new(contents: ['Right justified.', 'Another line of text'], justified: :right)
          b2 = TerminalGrid::Cell.new(contents: ['Right justified.'], justified: :right)
          grid.update(grid: [[a1, a2], [b1, b2]])
          puts grid

          a1_new = TerminalGrid::Cell.new(contents: ['Now I am', 'center justified'], justified: :center)
          grid.update_cell(cell: a1_new, row_index: 0, col_index: 0)
          puts grid
        end
      end
    end
  end
end
