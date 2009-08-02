# encoding: UTF-8

module Decider
  module Vectorize
    
    def vector(doc)
      @vector_prototype ||= vector_class.prototype(token_indices)
      @vector_prototype.new(doc)
    end
    
    #def binary_vector(document)
    #  @binary_vector_prototype ||= Vectors::SparseBinary.prototype(token_indices)
    #  @binary_vector_prototype.new(document)
    #end
    
    # def sparse_binary_vector(document)
    #   vector = {}
    #   document.tokens.each do |token|
    #     vector[token_indices[token]] = 1
    #   end
    #   vector.keys.sort
    # end
    
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
    
    def average_vectors(v1, v2)
      avg = []
      v1.size.times do |i|
        avg << ((v1[i].to_f + v2[i].to_f) / 2.0)
      end
      avg
    end
    
    def invalidate_cache
      @token_indices, @empty_vector = nil, nil
      @vector_prototype = nil
    end
    
    private
    
    # Builds a hash of 'token' => i where i is an autoincrementing integer.
    # Used elsewhere to (quickly) build a vector representation of a document
    def token_indices
      unless @token_indices
        @token_indices = {}
        # bloomfilter slower if there's not many cache misses :-(
        #                                  M,K,R
        #@token_indices = BloomFilter.new(20,3,1)
        index = 0
        sorted_classes.each do |klass|
          klass.tokens.each do |token|
            unless @token_indices[token]
              @token_indices[token] = index
              index += 1
            end
          end
        end
        @empty_vector = Array.new(index, 0)
      end
      return @token_indices
    end
    
    def empty_vector
      @token_indices || token_indices
      @empty_vector.dup
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
