require 'pry'

class Board
  attr_reader :data
  POSSIBLE_WINS = {
    1 => [[2,3],[4,7],[5,9]],
    2 => [[1,3],[5,8]],
    3 => [[1,2],[6,9],[5,7]],
    4 => [[1,7],[5,6]],
    5 => [[1,9],[2,8],[3,7],[4,6]],
    6 => [[4,5],[3,9]],
    7 => [[1,4],[8,9],[3,5]],
    8 => [[2,5],[7,9]],
    9 => [[7,8],[3,6],[1,5]]
  }

  def initialize
    @data = {}
    (1..9).each { |position| @data[position] = Square.new(' ') }
  end

  def draw
    system 'clear'
    puts "  #{@data[1]} | #{@data[2]} | #{@data[3]} "
    puts "----+---+----"
    puts "  #{@data[4]} | #{@data[5]} | #{@data[6]} "
    puts "----+---+----"
    puts "  #{@data[7]} | #{@data[8]} | #{@data[9]} "
  end

  def show_options
    puts "Please choose a spot to mark:#{joinor(empty_positions, ', ', 'and')}"
  end

  def joinor(positions, delimeter = ', ', conjunction = 'or')
    positions[-1] = "#{conjunction} #{positions[-1]}" unless positions.empty?
    positions.join(delimeter)
  end

  def empty_positions
    @data.select { |_,square| square.empty? }.keys
  end

  def taken_positions
    @data.select { |_,square| !square.empty? }.keys
  end

  def tie?
    empty_positions.size == 0
  end

  def mark_square(position, marker)
    @data[position].mark(marker)
  end
end

class Square
  def initialize(value)
    @value = value
  end

  def empty?
    @value == ' '
  end

  def marker
    @value
  end

  def mark(marker)
    @value = marker
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :name, :score
  attr_reader :marker

  def initialize(name, marker)
    @name = name
    @marker = marker
    @score = 0
  end
end

class Game
  attr_accessor :winner, :tie

  def initialize
    @board = Board.new
    name = ask_name
    marker = choose_marker
    @human_player = Player.new(name, marker)
    @computer_player = Player.new('C3PO',get_computer_marker)
    @current_player = initial_current_player
  end

  def ask_name
    puts "Please enter your name:"
    gets.chomp
  end

  def choose_marker
    puts "Please choose a marker(X or O)"
    gets.chomp
  end

  def get_computer_marker
    (['X','O'] - [@human_player.marker]).first
  end

  def reset
    @board = Board.new
    self.winner = nil
    self.tie = nil
    @current_player = initial_current_player
  end

  def initial_current_player
    @current_player =
      rand(2) == 0 ? @human_player : @computer_player
  end

  def change_current_player
    if @current_player == @human_player
      @current_player = @computer_player
    else
      @current_player = @human_player
    end
  end

  def mark_square
    if @current_player == @human_player
      begin
        position = gets.chomp.to_i
      end until @board.empty_positions.include?(position)
    else
      position = computer_picks_square
    end
    @board.mark_square(position, @current_player.marker)
  end

  def computer_picks_square
    attack = move_if_two_in_a_row(@computer_player.marker)
    defense = move_if_two_in_a_row(@human_player.marker)
    computer_choice = attack if attack
    computer_choice = defense if !computer_choice && defense
    computer_choice = @board.empty_positions.sample unless computer_choice
    computer_choice
  end

  def move_if_two_in_a_row(marker)
    if @board.taken_positions.size >= 2
      move =
      @board.empty_positions.find do |empty_position|
        Board::POSSIBLE_WINS[empty_position].any? do |value|
          @board.data[value[0]].marker == marker &&
          @board.data[value[1]].marker == marker
        end
      end
    end

    return move
  end

  def winner?(marker)
    @board.taken_positions.find do |taken_position|
      Board::POSSIBLE_WINS[taken_position].any? do |value|
        @board.data[taken_position].marker == marker &&
        @board.data[value[0]].marker == marker &&
        @board.data[value[1]].marker == marker
      end
    end
  end

  def say_winner
    puts "#{@current_player.name} has gotten 3 in a row and wins the game."
  end

  def say_tie
    puts "This is a cat's game and it ends in a tie."
  end

  def current_player_takes_turn
    mark_square
    if winner?(@current_player.marker)
      @winner = @current_player
      @current_player.score += 1
    end
    @tie = @board.tie?
  end

  def play_again?
    puts "Would you like to play again?"
    answer = gets.chomp.downcase
    ['yes','yea','y'].include?(answer)
  end

  def say_score
    puts "Player: #{@human_player.score} |  Computer: #{@computer_player.score}"
  end

  def game_over
    if @current_player.score == 5
      puts "You've reached 5 points!"
      exit
    end
  end

  def play
    loop do
      @board.draw
      @board.show_options unless winner || tie
      say_winner if winner
      say_tie if tie
      if tie || winner
        say_score
        break
      end
      game_over
      change_current_player
      current_player_takes_turn
    end
  end
end

game = Game.new
loop do
  game.play
  sleep(2)
  if game.play_again?
    game.reset
    next
  end
  puts "Thanks for playing!"
  break
end
