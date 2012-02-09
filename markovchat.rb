require 'pp'
require 'cached_hash'

class MarkovChat

  attr_accessor :dbfile

  def initialize(dbfile="markov.db")
    @dbfile = dbfile
    @nextwords = CachedHash.new
    @nextwords_total = {}
  end
  
  def database
    @nextwords
  end
  
  def nw
    @nextwords
  end

  def random_pair
    @nextwords.random_key
  end
  
  def pair_starting_with(word)
    word = word.to_sym
    @nextwords.find_random_key{|k| k.first == word}
  end

  def random_start
    until (ks = random_pair).first.nil?; end
    #ks = @nextwords.keys.select{|ws| ws[0] == nil }
    #w0, w1 = ks[ rand(ks.size) ]
    w0, w1 = ks
    [w1, nextword(w0,w1)]
  end

  def chat(*args)
    args = pair_starting_with(args.first) if args.size == 1

    while args.size != 2 or args.any?{|arg| arg.nil?} 
      args = random_start
    end
    
    w1, w2    = args.map{|w| w.to_sym}
    sentence  = [w1, w2]

    while nw = nextword(w1, w2)
      sentence << nw
      w1,w2 = w2,nw
    end
    
    sentence.join(" ")
  end

  def total(key)
    @nextwords_total[key] ||= 0
  end

  def inc_total(key)  
    @nextwords_total[key] ||= 0
    @nextwords_total[key] += 1
  end
  
  def nextwords(key)
    @nextwords[key] ||= {}
  end

  def nextword(w1, w2)
    #p [:nextword, w1, w2]
    key     = [w1,w2]
    nexts   = nextwords(key)
    thresh  = rand(total(key))
    total   = 0
    nw      = nil
    
    for word, num in nexts
      total += num
      if total > thresh
        nw = word
        break
      end
    end
    
    nw
  end
  
  def add_sentence(sentence)
    ws = [nil] + sentence.split.map{|w| w.to_sym} + [nil]
    for i in (0...ws.size-2)
      add_triple( *ws[i..i+2] )
    end
  end
  
  def add_triple(w1, w2, w3)
    key = [w1,w2]
    nexts = nextwords(key)
    nexts[w3] ||= 0
    nexts[w3] += 1
    inc_total(key)
  end
  
  def dump
    puts "-"*50
    puts "Contents of markov database:"
    puts "="*50
    pp [:nextwords, @nextwords]
    puts
  end

  def tempfile
    "#{dbfile}.temp"
  end
  
  def locked?
    File.exists?(tempfile)
  end
  
  def save
    if locked?
      puts "+ Error! Can't save because #{tempfile.inspect} already exists."
      puts "  (Either we're already saving in the background, or you crashed before and"
      puts "   you should delete that file.)"
      
      false
    else
      puts "+ Writing #{tempfile}..."
      open(tempfile, "wb") do |f|
        f.write Marshal.dump([@nextwords, @nextwords_total])
      end
      
      if File.exists?(dbfile)
        puts "  |_ backing up #{dbfile} (to .bak)..."
        File.rename(dbfile, "#{dbfile}.bak")
      end
      
      puts "  |_ moving #{tempfile} into place"
      File.rename(tempfile, dbfile)
      
      puts "  |_ Done!"
      puts

      true
    end
  end
  
  #
  # Save the database in the background (by forking) 
  #
  def background_save
    Process.detach( fork { save } )
  end
  
  def load
    puts "Loading #{dbfile}..."
    open(dbfile) do |f|
      @nextwords, @nextwords_total = Marshal.load(f.read)
    end
    
    unless @nextwords.is_a? CachedHash
      puts "*** Upgrading Hash to a CachedHash! ***"
      @nextwords = @nextwords.to_cached_hash
    end
    
    puts "  |_ Done! #{@nextwords.size} pairs..."
    puts
  end
  
end



if $0 == __FILE__

  m = MarkovChat.new
  
  m.add_sentence("hi there how are you")
  m.add_sentence("how is trix doing")
  m.add_sentence("hey dude what's up")
  m.add_sentence("totally man")
  m.add_sentence("hi there you are groovy")
  m.add_sentence("hi there you are amazing")
  m.add_sentence("hi there you are a manly man")
  
  m.save
  
  m.background_save
  
  #puts "hit enter to continue..."; gets
  
  n = MarkovChat.new
  while m.locked?; sleep 0.1; end
  puts "lock released!"
  n.load
  n.dump
  
  p [:pair_starting_with, n.pair_starting_with("hi")]
  p [:pair_starting_with, n.pair_starting_with("hi")]
  
  p n.chat("hi", "there")
  
  
  5.times do
    p n.chat
  end
  
end