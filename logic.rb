class Bit
  attr_accessor :state
  STATES=[:zero,:one]
  def initialize(state)
    if STATES.include? state
      self.state = state
    else
      raise "initialization value out of range, use :zero or :one"
    end
  end
  def self.states
    STATES
  end
  def self.zero
    self.new(STATES[0])
  end
  def self.one
    self.new(STATES[1])
  end
end

class Gate
  AND_TABLE = {Bit.states[0] => {Bit.states[0] => Bit.zero, Bit.states[1] => Bit.zero}, Bit.states[1] => {Bit.states[0] => Bit.zero, Bit.states[1] => Bit.one}}
  OR_TABLE = {Bit.states[0] => {Bit.states[0] => Bit.zero, Bit.states[1] => Bit.one}, Bit.states[1] => {Bit.states[0] => Bit.one, Bit.states[1] => Bit.one}}

  def self.and(bit1,bit2)
    return AND_TABLE[bit1.state][bit2.state]
  end
  def self.or(bit1,bit2)
    return OR_TABLE[bit1.state][bit2.state]
  end
  def self.not(bit)
    return bit.state == :zero ? Bit.one : Bit.zero
  end
  def self.xor(bit1,bit2)
    o = self.or(bit1,bit2)
    na = self.not(self.and(bit1,bit2))
    return self.and(o,na)
  end
  def self.nor(bit1,bit2)
    return self.not(self.or(bit1,bit2))
  end
end