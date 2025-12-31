# frozen_string_literal: true

module Euchre
  module GameState
    Context = Struct.new(
      :players, # A struct, has south, east, north, west, (Players) team1, team2 (Arrays of Players). Set by PlayerManager
      :display_order, # An array of Players, immutable. Set by PlayerManager
      :player_order, # An array of Players. Set by PlayerManager, mutated by TrickManager and DealManager
      :dealer, # A Player. Set by PlayerManager (or by DealManager if random dealer), mutated by DealManager
      :center_card, # A Card. Set by DealManager, mutated by BidManager
      :center_card_suit, # A SUIT. Set by DealManager, mutated by DealManager
      :score, # A hash. Set by ScoreManager
      :bid, # A struct, has pass, trumps, going_alone, bidders, defenders. Set by BidManager
      :tricks, # An Array of Tricks. Set by TrickManager
      :result # Set by TrickManager - winning team, points
    )
  end
end
