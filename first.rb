class Bit
  STATES = ["off", "on"]
  def say_hello
    puts STATES[1]
  end
end

class Logic
  def self.and(v1,v2)
    return v1 && v2
  end
  def self.or(v1,v2)
    return v1 || v2
  end
end

puts Logic.or(true,true)
puts Logic.or(true,false)
puts Logic.or(false,true)
puts Logic.or(false,false)

