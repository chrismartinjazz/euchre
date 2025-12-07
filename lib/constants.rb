# frozen_string_literal: true

BOWER_RANK = :J
LEFT_BOWER_RANK = :left_bower
JOKER_RANK = :'?'
RANKS = {
  non_trumps: (%i[9 T] + [BOWER_RANK] + %i[Q K A]).freeze,
  trumps: (%i[9 T Q K A] + [LEFT_BOWER_RANK, BOWER_RANK, JOKER_RANK]).freeze
}.freeze

CLUB_SUIT = :C
DIAMOND_SUIT = :D
HEART_SUIT = :H
SPADE_SUIT = :S
JOKER_SUIT = :J

SUITS = {
  CLUB_SUIT => {
    text: 'Clubs',
    glyph: '♣',
    color: 'black'
  },
  DIAMOND_SUIT => {
    text: 'Diamonds',
    glyph: "\e[31m♦\e[0m",
    color: 'red'
  },
  HEART_SUIT => {
    text: 'Hearts',
    glyph: "\e[31m♥\e[0m",
    color: 'red'
  },
  SPADE_SUIT => {
    text: 'Spades',
    glyph: '♠',
    color: 'black'
  },
  JOKER_SUIT => {
    text: 'Joker',
    glyph: 'J',
    color: 'joker'
  }
}.freeze
