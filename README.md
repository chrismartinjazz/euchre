# Euchre

A terminal implementation of the card game Euchre, using Australian style rules and 4 players.

## Features

- Bidding over two rounds, going alone, play tricks
- Terminal updates with each play to display player hands and trick progress
- Leading and following suit, also indicated on terminal display
- Only accepts valid cards to play and re-prompts with valid card options if player makes a mistake
- Basic computer AI will:
  - Evaluate potential bidding hands and decide whether to bid and whether or not to go alone
  - Play aggressively with the best card in hand unless it cannot win the trick
  - When exchanging a card, discard off-trump, non-ace singles in preference to other lower rank cards if it holds some trumps

## Code

- Implements a basic Object Factory for Cards
- Polymorphic HumanPlayer / ComputerPlayer objects respond to messages
- Basic test coverage with Rspec with key unit tests and integration tests
- constants.rb includes the suits, ranks, and some settings for gameplay and display.
- TerminalGrid module allows justifying text within cells left, right, center, cells of variable widths.
