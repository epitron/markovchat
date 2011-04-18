# MarkovChat for Ruby

A markov chain for sentences. 

To train it, you shove in a bunch of sentences. Then, it lets you output probabilistic sentences!

Optionally, you can save the markov chain to a file for later. (The default filename is `markov.db`.)

The file format is a standard Ruby `Hash` serialized to binary using `Marshal`. If you want to hack it, that's a pretty easy solution. :)

# Examples

## Initializing, training, and generating random chatter:

    m = MarkovChat.new
    
    m.add_sentence("hi there how are you")
    m.add_sentence("how is trix doing")
    m.add_sentence("hey dude what's up")
    m.add_sentence("totally man")
    m.add_sentence("hi there you are groovy")
    m.add_sentence("hi there you are amazing")
    m.add_sentence("hi there you are a manly man")

    5.times { p n.chat }
    
## Generate sentences that start with specific words:

    m.chat("hi", "there")
    
## Saving the markov chain:
    
    m.save

## Saving the markov chain to `CNN.db`:
    
    m = MarkovChat.new("CNN.db")
    m.save
    
## Saving the markov chain in a forked background process (so it won't freeze your IRC bot):    
    
    m.background_save

## Loading the markov chain from a file:

    m = MarkovChat.new("oldchain.db")
    m.load
    
## Changing the db file mid-stream:

    m = Markovchat.new("oldchain.rb")
    <.. do some stuff ..>
    m.dbfile = "newchain.db"
    m.save

## Accessing the internal database (as a Ruby `Hash`):

    m.database

## Dumping the database to JSON:

    require 'json'
    open("markov.json", "w") { |f| f.write( JSON.dump m.database ) }
    
