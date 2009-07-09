# Bayes implementation should have a performance enhancement for 2 class case
#
# For 2 classes, optimize by only computing probability for one class in step 2;
# decide based on (result <=> .50)

Feature: One Class SVM (aka boundary detection)
  In order to more accurately detect anomalies 
  And waste less of the users' time with false positives and negatives
  As a decider
  I want to detect anomalous documents via one class SVM

# NOTES:
# each document in training set converted to a vector like this:
# document "token1 token3"
# vectorspace = [token1, token2,token3, ...]
# document.to_vector => [1,0,1, ...]
# ** Try to find a way to do this in C/C++, slow as hell in ruby **
# Feed this into libsvm
# To test unknowns, turn them into vectors as well, then feed to libsvm
# Other vectorization strategies also exist...
#
# Vectorization currently resides in the TrainingSet class; this needs to
# be extracted to a module that will be included in Classifier. Can't work
# the way it is now (all docs should be in one vector space).

Feature: HTML Tokenization
  In order to apply the classification to HTML documents
  As a decider
  I want an HTML tokenizer

## Cool ML Techniques to Implement ##
#
# Sparse Binary Polynomial Hashing (super sweet tokenization routine)
#
# NOTES:
# From _Ending Spam_ by Jonathan Zdziarski
# SBPH Turns the phrase:
#   An uncommon offer for an
# Into:
#   An
#   An uncommon
#   An <skip> offer
#   An uncommon offer
#   An <skip> <skip> for
#   An uncommon <skip> for
#   An uncommon offer for
#   An <skip> <skip> <skip> an
#   An uncommon <skip> <skip> an
#   An <skip> offer <skip> an
#   An uncommon offer <skip> an
#   An <skip> <skip> for an
#   An uncommon <skip> for an
#   An <skip> offer for an
#   An uncommon offer for an
# 

# Markovian Algorithm (Hidden Markov Model)
# 
# If there's a way to turn an intermediate step into a score that could be used
# for anomaly detection, that would be teh awesome. OTOH, ngrams + bayes are
# apparently quite similar in effect.
# 

Feature: Moneta Back-end
  In order to allow for distributed processing and long term storage with minimal effort
  As a decider
  I want to use a moneta key/value store for my documents

Feature: Setting raw text based on method call
  In order to integrate better with ORM objects and the like
  As a decider
  I want to be able to set the raw text of a document with an arbitrary method call to the raw text

# something like:
# TrainingSet.new do |doc|
#   doc.extract(:method_to_send, *args)
#   *OR*
#   doc.extract {|original_doc| doc.text_i_care_about}
# end
