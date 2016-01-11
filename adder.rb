# Make switches and 'on' 'off' states more explicit
# Make add/subtract using xor to invert/not-invert

require "./logic"

class Adder
  def self.to_bits(value)
    v = value
    bits = []
    while v > 1
      bits.push(v%2==0 ? Bit.zero : Bit.one)
      v = v/2
    end
    bits.push(value > 0 ? Bit.one : Bit.zero)
    return bits
  end

  def self.to_number(bit_set)
    result = 0
    bit_set.each_with_index do |a,i|
      factor = a.state==Bit.zero.state ? 0 : 1
      result += factor*(2**i)
    end
    return result
  end

  def self.half_adder(a,b)
    [Gate.xor(a,b),Gate.and(a,b)]
  end

  def self.full_adder(a,b,c)
    half = half_adder(a,b)
    full = half_adder(c,half[0])
    [full[0],Gate.or(full[1],half[1])]
  end

  def self.add_each(a1,a2)
    result = []
    c = Bit.zero
    a1.each_with_index do |a,i|
      s = i>=a2.size ? full_adder(a,Bit.zero,c) : full_adder(a,a2[i],c)
      c = s[1]
      result.push(s[0])
    end
    result.push(c) if c.state == Bit.one.state
    return result
  end
 
  def self.add(val1,val2)
    val1_array = Adder.to_bits(val1)
    val2_array = Adder.to_bits(val2)
    if val1_array.size > val2_array.size
      result = add_each(val1_array,val2_array)
    else
      result = add_each(val2_array,val1_array)
    end
    return to_number(result)
  end
  def self.subtract(val1,val2)
    val1_array = Adder.to_bits(val1>val2 ? val1 : val2)
    val2_array = Adder.to_bits(val1>val2 ? val2 : val1).map{|b| Gate.not(b)}
    val2_array.size
    (val1_array.size-val2_array.size).times{|c| val2_array.push(Bit.one)}
    if val1_array.size > val2_array.size
      result = add_each(val1_array,val2_array)
    else
      result = add_each(val2_array,val1_array)
    end
    r2 = add_each(result,[Bit.one])
    r2.pop 
    return to_number(r2)*(val1>val2 ? 1 : -1)
  end  
end

