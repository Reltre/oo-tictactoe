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

  def empty_positions
    @data.select { |_,square| square.empty? }.keys
  end

  def taken_positions
    @data.select { |_,square| !square.empty? }.keys
  end

  def is_empty?
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
  attr_accessor :name
  attr_reader :marker

  def initialize(name, marker)
    @name = name
    @marker = marker
  end
end

class Game
  attr_accessor :winner

  def initialize
    @board = Board.new
    puts "Please enter your name:"
    @human_player = Player.new(gets.chomp, 'X')
    @computer_player = Player.new('C3PO','O')
    @current_player = initial_current_player
  end

  def reset
    @board = Board.new
    @winner = nil
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
        puts "Please choose a spot to mark:#{@board.empty_positions*','}"
        position = gets.chomp.to_i
      end until @board.empty_positions.include?(position)
    else 
      position = computer_picks_square
    end
    @board.mark_square(position, @current_player.marker)
  end
  
  def computer_picks_square
    if computer_choice = move_if_two_in_a_row(@computer_player.marker)
      nil
    elsif computer_choice = move_if_two_in_a_row(@human_player.marker)
      nil
    else
      computer_choice = @board.empty_positions.sample 
    end
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
    @board.draw
    if winner?(@current_player.marker)
      @winner = @current_player
      say_winner
    end
  end

  def play_again?
    puts "Would you like to play again?"   
    answer = gets.chomp.downcase
    ['yes','yea','y'].include?(answer) 
  end

  def play
    @board.draw
    loop do
      current_player_takes_turn
      break if winner == @current_player
      if @board.empty_positions.size == 0 
        say_tie
        break
      end
      change_current_player
    end
  end
end

game = Game.new 
loop do
  game.play
  sleep(3)
  continue_game = game.play_again?
  game.reset if continue_game
  puts "Thanks for playing!"; break if !continue_game
end 