# encoding: UTF-8

module Decider
  module Vectorize
    
    def binary_vector(document)
      vector = empty_vector
      document.tokens.each do |token|
        index_of_token = token_indices[token]
        vector[index_of_token] = 1 if index_of_token
      end
      vector
    end
    
    def proportional_vector(document)
      vector = empty_vector
      token_frequencies = token_frequency_hsh(document.tokens)
      token_frequencies.each do |token, frequency|
        vector[token_indices[token]] = frequency
      end
      vector
    end
    
    def euclidean_coefficient(vector1, vector2)
      1.0 / (1.0 + euclidian_distance(vector1, vector2))
    end
    
    def pearson_coefficient(vector1, vector2)
      n = vector1.size
      coproducts = Range.new(0, n - 1).map { |i| (vector1[i] * vector2[i]) }
      covariance = Math.sum_floats(coproducts) / n
      vector1_stddev, vector2_stddev = vector_stddev(vector1), vector_stddev(vector2)
      denominator = (vector1_stddev * vector2_stddev)
      denominator == 0 ? 1.0 : covariance / denominator
    end
    
    def tanimoto_coefficient(v1, v2)
      v1.dot(v2) / ((v1.dot(v1) + v2.dot(v2) - v1.dot(v2)))
    end
    
    def average_vectors(v1, v2)
      avg = []
      v1.size.times do |i|
        avg << ((v1[i].to_f + v2[i].to_f) / 2.0)
      end
      avg
    end
    
    def invalidate_cache
      @token_indices = nil
    end
    
    # "Averaging" binary vectors is sorta meaningless. Nevertheless,
    # this is needed to create the virtual nodes (i.e. groups) for 
    # Clustering::Node. This method uses "AND" logic. "OR" might be the better
    # choice...
    def avg_binary_vectors(v1,v2)
      avg = []
      v1.size.times do |i|
        avg << (v1[i].to_i + v2[i].to_i) / 2 
      end
      avg
    end
    
    private
    
    # Builds a hash of 'token' => i where i is an autoincrementing integer.
    # Used elsewhere to (quickly) build a vector representation of a document
    def token_indices
      unless @token_indices
        @token_indices = {}
        index = 0
        sorted_classes.each do |klass|
          klass.tokens.each do |token|
            unless @token_indices.has_key?(token)
              @token_indices[token] = index
              index += 1
            end
          end
        end
      end
      @token_indices
    end
    
    def empty_vector
      Array.new(token_indices.size, 0)
    end
    
    def euclidian_distance(vector1, vector2)
      sum_of_squares_of_distances = 0
      vector1.size.times do |i|
        sum_of_squares_of_distances += ((vector1[i].to_f - vector2[i].to_f) ** 2)
      end
      Math.sqrt(sum_of_squares_of_distances)
    end
    
    def vector_stddev(vector)
      Math.sqrt(Math.sum_floats(vector.map { |x| x ** 2 }) / vector.size)
    end
    
    def token_frequency_hsh(tokens)
      token_count = tokens.size.to_f
      frequency = Hash.new(0.0)
      tokens.each do |token|
        frequency[token] += 1.0 / token_count
      end
      frequency
    end
    
  end
end
