require 'pp'

class MarkovChat

  attr_accessor :dbfile

  def initialize(dbfile="default.db")
    @dbfile = dbfile
    @nextwords = {}
    @nextwords_total = {}
  end

  def random_pair
    ks = @nextwords.keys
    ks[ rand(ks.size) ]
  end

  def random_start
    ks = @nextwords.keys.select{|ws| ws[0] == nil }
    w0, w1= ks[ rand(ks.size) ]
    [w1, nextword(w0,w1)]
  end

  def chat(*args)
    args      = random_start unless args.size == 2
    w1, w2    = args.map{|w| w.to_sym}
    sentence  = [w1, w2]

    loop do 
      break unless nw = nextword(w1, w2)
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
    #pp [:nextwords_total, @nextwords_total]
    puts
  end
  
  def save
    tempfile = "#{dbfile}.temp"
    if File.exists?(tempfile)
      puts "+ Error! Can't save because #{tempfile.inspect} already exists."
      puts "  (Either we're already saving in the background, or you crashed before and"
      puts "   you should delete that file.)"
      return
    end
    
    fork do
      puts "+ Writing #{tempfile} (in background)..."
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
    end
    
  end
  
  def load
    puts "Loading #{dbfile}..."
    open(dbfile) do |f|
      @nextwords, @nextwords_total = Marshal.load(f.read)
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
  puts "hit enter to continue..."; gets
  
  n = MarkovChat.new
  n.load
  n.dump
  
  p n.chat("hi", "there")
  
  5.times do
    p n.chat
  end
  
end