# frozen_string_literal: true

module Euchre
  module GameState
    Bid = Struct.new(
      :pass,
      :trumps,
      :going_alone,
      :bidder,
      :bidders,
      :defenders
    )
  end
end
