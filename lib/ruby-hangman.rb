def random_word
  wordlist = File.readlines('google-10000-english-no-swears.txt')
  wordlist = wordlist.map(&:chomp) # wordlist.map{|w| w.chomp}
  good_word = false
  word = ''
  until good_word
    word = wordlist[Random.rand(10000)]
    good_word = true if word.length >= 5 && word.length<=12 
  end
  word
end
