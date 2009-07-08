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
