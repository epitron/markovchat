# MarkovChat for Ruby

A markov chain for sentences. (For the uninitiated, a Markov chain is a probabilistic model of a thing which can generate random examples of that thing. In this case, it can eat sentences, and produce new random sentences.)

To train the model, you shove in a bunch of sentences. Then, it will generate probabilistic sentences!

Optionally, you can save the markov chain to a file for later. (The default filename is `markov.db`.)

The file format is a standard Ruby `Hash` serialized to binary using `Marshal`. If you want to hack it, that's a pretty easy solution. :)

# Examples

## Initialize, train, and generate random sentences:

```ruby
m = MarkovChat.new

m.add_sentence("hi there how are you")
m.add_sentence("how is trix doing")
m.add_sentence("hey dude what's up")
m.add_sentence("totally man")
m.add_sentence("hi there you are groovy")
m.add_sentence("hi there you are amazing")
m.add_sentence("hi there you are a manly man")

5.times { p n.chat }
```    

## Generate sentences that start with specific words:

```ruby
m.chat("hi", "there")
```
    
## Save the markov chain:
    
```ruby
m.save
```

## Save the markov chain to `CNN.db`:
    
```ruby
m = MarkovChat.new("CNN.db")
m.save
```
    
## Save the markov chain in a forked background process (so it won't freeze your IRC bot):

```ruby
m.background_save
```
## Load the markov chain from a file:

```ruby
m = MarkovChat.new("oldchain.db")
m.load
```
    
## Change the db filename mid-stream:

```ruby
m = Markovchat.new("oldchain.db")
<.. do some stuff ..>
m.dbfile = "newchain.db"
m.save
```

## Access the internal database (as a Ruby `Hash`):

```ruby
m.database
```

## Dump the database to a JSON file:

```ruby
require 'json'
open("markov.json", "w") do |f|
  f.write( JSON.dump m.database )
end
```
