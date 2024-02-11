require 'pry-byebug'
require 'json'

class Hangman
  attr_accessor :parts,:complete_parts
    @complete_parts = ['','O','/','\\','|','/','\\','│','╱','╒══════════╕','┊']
    @parts=['',' ',' ',' ' ,' ',' ',' ' ,' ',' ','            ',' ']

  def self.show_saved_data
    data = JSON.load(File.read('game_saves.json'))
    self.new.display_panel(data['parts'])
      puts "chosen_word = #{data['chosen_word']}"
      puts "guessed_word = #{data['guessed_word']}"
      puts "failure = #{data['failure']}"
      puts "letters = #{data['letters']}"
  end

  def display_panel (pt)
    puts
    puts '   ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂'
    puts '  ▌                                            █'
    puts '  ▌ ██  ██                                 ██  █'
    puts '  ▌ ██  ██ ▄▄▄▄ ▄▄▄▄ ▄▄▄▄ ▄▄▄▄▄ ▄▄▄▄ ▄▄▄▄  ██  █'
    puts '  ▌ ██████ █  █ █  █ █  █ █ █ █ █  █ █  █  ██  █'
    puts '  ▌ ██  ██ █▄▄█ █  █ █▄▄█ █ █ █ █▄▄█ █  █      █'
    puts '  ▌ ██  ██ █  █ █  █ ▄▄▄▛ █ █ █ █  █ █  █  ██  █'
    puts '  ▚▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█'
    puts
      puts"                 #{pt[9]}    "
      puts"                 #{pt[7]}   #{pt[8]}#{pt[8]}     #{pt[10]}    "
      puts"                 #{pt[7]}  #{pt[8]}#{pt[8]}      #{pt[10]}    "
      puts"                 #{pt[7]} #{pt[8]}#{pt[8]}       #{pt[1]}    "
      puts"                 #{pt[7]}#{pt[8]}#{pt[8]}       #{pt[2]}#{pt[4]}#{pt[3]}  "
      puts"                 #{pt[7]}#{pt[8]}         #{pt[4]}    "
      puts"                 #{pt[7]}         #{pt[5]} #{pt[6]}  "
      puts"                 #{pt[7]}               "
      puts"              ___#{pt[7]}______________ "
      puts
  end

  def random_word
    wordlist = File.readlines('google-10000-english-no-swears.txt')
    wordlist = wordlist.map(&:chomp) # wordlist.map{|w| w.chomp}
    good_word = false
    word = ''
    until good_word
      word = wordlist[Random.rand(10000)]
      good_word = true if word.length >= 5 && word.length<=12 
    end
    word.upcase
  end

  def get_guess
    guess = ''
    until guess.length == 1 && guess.match?(/[A-Za-z]/)
      print "take a guess: "
      guess = gets.chomp.upcase
    end
    guess
  end

  def analize_guess(chosen_word, letter='', guessed_word)
    indexes = (0...chosen_word.length).select{|i| chosen_word[i]==letter}
    indexes.each{|i| guessed_word[i]=letter}
    guessed_word
  end

  def clear
    system 'clear'
  end

  def save_game(chosen_word,letters,guessed_word,failure)
    data = JSON.dump({
      'parts'=>parts,
      'chosen_word'=>chosen_word,
      'failure'=>failure,
      'letters'=>letters,
      'guessed_word'=>guessed_word
    })
    nice = File.open('game_saves.json','w+')
    nice.puts data
    nice.pos
  end

  def does_continue?
    print 'continue from saved game? (y/n): '
    gets.chomp.downcase == 'y'
  end

  def put_saved_game
    JSON.load(File.read('game_saves.json'))
  end

  def play(chosen_word,guessed_word,parts=@parts,letters='',failure=0)
    guess = ''
    while guessed_word != chosen_word && failure<10
      display_panel(parts)
      print "guessed letters = #{guessed_word}"
      puts
      puts letters
      puts
      print 'save the games for this turn? (overwrite previous data) (y/n/exit) :'
      is_stored = gets.chomp.downcase
      if is_stored == 'exit'
        return 'Quit'
      end
      guess = get_guess

      failure+=1 unless chosen_word.include?(guess) || letters.include?(guess)
      parts[failure] = complete_parts[failure]
      letters+=guess unless letters.include?(guess)
      guessed_word = analize_guess(chosen_word,guess,guessed_word)

      save_game(chosen_word,letters,guessed_word,failure) if is_stored == 'y'
    end
    self.parts = parts
    guessed_word == chosen_word ? 'WON' : 'LOSE' 
  end

  def start 
    is_again = true
    while is_again
      if does_continue?
        result = play(put_saved_game['chosen_word'],put_saved_game['guessed_word'],put_saved_game['parts'],put_saved_game['letters'],put_saved_game['failure'])
        puts"#### you #{result} ####"
      else
        chosen_word = random_word
        result = play(chosen_word,'_' * chosen_word.length)
        puts"#### you #{result} ####"
        puts "# {chosen_word} the word is #{chosen_word}\n" unless result =='Quit'
      end
      clear
      display_panel(parts)
      print 'again? (y/n)'
      is_again = gets.chomp.downcase=='y'
    end
    puts 'GOODBYE'
  end
end

# new_game = Hangman.new.start
binding.pry
'goof'
#here is what you can do
# change the important variables into instance variables
# 