# encoding: UTF-8

module Decider
  module Vectorize
    
    def token_indices
      token_indices_hsh = {}
      index = 0
      sorted_classes.each do |klass|
        klass.tokens.each do |token|
          unless token_indices_hsh.has_key?(token)
            token_indices_hsh[token] = index
            index += 1
          end
        end
      end
      token_indices_hsh
    end
    
    def emtpy_vector
      Array.new(token_indices.size, 0)
    end
    
    def binary_vector(document)
      vector = emtpy_vector
      new_document(document).tokens.each do |token|
        index_of_token = token_indices[token]
        vector[index_of_token] = 1 if index_of_token
      end
      vector
    end
    
  end
end
