# encoding: UTF-8

module Math
  
  # Variance of a population. If computing the variance of the entire 
  # population, defaults are fine. If computing the variance of a sample of the
  # population, enable the "Bessel Correction" with <tt>:sample => true</tt>
  # Algorithm: Knuth/Welford 
  # http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#On-line_algorithm
  def variance(population, opts={:sample=>false})
    n, mean, s = 0, 0.0, 0.0
    population.each do |x|
      n += 1
      delta = x - mean
      mean += (delta / n)
      s += delta * (x - mean)
    end
    return opts[:sample] ? s / (n - 1.0) : s / n
  end
  
  # Standard Deviation of a population. For a sample of a population, you need
  # to provide <tt>:sample => true</tt> (See #variance for more)
  def stddev(population, opts={:sample=>false})
    sqrt(variance(population, opts))
  end
  

  def avg(pop)
    total = pop.inject(0) { |sum, n| sum + n }
    total.to_f / pop.size.to_f
  end
  
  def sum_floats(array)
    array.inject(0.0) { |sum, element| sum + element }
  end
  
  module_function :variance, :avg, :stddev, :sum_floats
  
end


class Hash
  
  def map_vals(&block)
    return_hsh = {}
    self.each do |key, val|
      return_hsh[key] = block.call(val)
    end
    return_hsh
  end
  
end

class String
  
  def to_const
    const_names = self.split("/").map do |const_name|
      const_name.split("_").map { |word| word.capitalize }.join("")
    end
    root = Module.const_get(const_names.shift)
    const_names.inject(root) { |const, const_name| const.const_get(const_name)}
  end
  
end

class Symbol
  
  def <=>(other)
    self.to_s <=> other.to_s
  end
  
end

class Array
  
  def dot(other_array)
    case size <=> other_array.size
    when 0,-1
      elements = size
    when 1
      elements = other_array.size
    end
      
    dot_product = 0
    elements.times { |i| dot_product += self[i] * other_array[i] }
    dot_product
  end
  
end