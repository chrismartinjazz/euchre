# frozen_string_literal: true

require 'trick_manager'
require 'human_player'
require 'card'

RSpec.describe TrickManager do
  context 'with four players, south, west, north and east' do
    south = Player.new(name: "South")
    west = Player.new(name: "West")
    north = Player.new(name: "North")
    east = Player.new(name: "East")

    it 'initializes with no winner or points' do
      tricks = TrickManager.new(
        trumps: :C,
        going_alone: false,
        bidding_team: [north, south],
        player_order: [south, west, north, east]
      )
      expect(tricks.winner).to eq nil
      expect(tricks.points).to eq nil
    end
  end
end
