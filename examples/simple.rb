require "rubygems"
require File.dirname(__FILE__) + "/../lib/decider"

c = Decider.classifier(:bayes, :spam, :ham) do |doc|
  doc.plain_text
  doc.ngrams(2..3)
  doc.stem
end

c.spam << "buy viagra, jerk" << "get enormous hot dog for make women happy"
c.ham << "check out my code on github homie" << "let's go out for beers after work"

p c.spam?("viagra for huge hot dog")
# => true
puts "term frequencies:"
puts "spam: #{c.spam.term_frequency.inspect}"
puts "ham:  #{c.ham.term_frequency.inspect}"
#p c.probabilities_for_token("women")
#p c.probabilities_for_token("code")
#p c.probabilities_for_tokens(["lets", "write", "code", "and", "drink", "some", "beer"])
p c.scores("let's write code and drink some beers")
p c.classify("let's write code and drink some beers")
# => :ham