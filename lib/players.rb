# frozen_string_literal: true

# Players and their teams. Teams should be stored as an array of two Player type objects.
Players = Struct.new(:south, :west, :north, :east, :team1, :team2)
