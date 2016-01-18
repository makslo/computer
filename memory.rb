# implicit memory in the wire & battery
# follow electricity in memory circuit wires
require "./adder"
require "./logic"

class OneBitMemory
  attr_accessor :data
  attr_accessor :clock
  attr_accessor :r_o
  attr_accessor :s_o
  def initialize(clock=Bit.zero)
    @data = Bit.zero
    @clock = clock
    @r_o = Bit.zero
    @s_o = Bit.one
  end
  def get_r
    Gate.and(Gate.not(@data),@clock)
  end
  def get_s
    Gate.and(@data,@clock)
  end
  def run(clear=Bit.zero)
    # Have to run the gates a few times to stabilize
    @r_o = Gate.nor(Gate.or(get_r,clear),Gate.nor(get_s,@r_o))
    @s_o = Gate.nor(get_s,Gate.nor(get_r,@s_o))
  end
  def edge_triggerd_run(clock, clear=Bit.zero)
    if @clock.state == Bit.zero.state && clock.state == Bit.one.state
      @clock = clock
      @r_o = Gate.nor(Gate.or(get_r,clear),Gate.nor(get_s,@r_o))
      @s_o = Gate.nor(get_s,Gate.nor(get_r,@s_o))
    else
      @clock = clock
    end
  end
end

class Oscillator
  attr_accessor :o
  def initialize
    @o = Bit.one
  end
  def set(value)
    @o = value
  end
  def run
    @o = Gate.not(@o)
  end
end

class FreqDivider
  def initialize(size)
    @size = size
    @dividers = [Oscillator.new]
    (@size-1).times do |i|
      i==0 ? @dividers.push(OneBitMemory.new(@dividers[i].o)) : @dividers.push(OneBitMemory.new(@dividers[i].s_o))
    end
  end
  def run
    @dividers[0].run
    (@size-1).times do |i|
      d = @dividers[i+1]
      d.data = d.s_o
      i==0 ? d.edge_triggerd_run(@dividers[i].o) : d.edge_triggerd_run(@dividers[i].s_o)
    end
  end
  def set_count(values)
    @dividers[0].set(Gate.not(values[0]))
    values[1..-1].each_with_index do |d,i|
      @dividers[i+1].r_o = values[i+1]
      @dividers[i+1].s_o = Gate.not(values[i+1])
      i==0 ? @dividers[i+1].clock=@dividers[i].o : @dividers[i+1].clock=@dividers[i].s_o
    end
  end
  def get_count
    [Gate.not(@dividers[0].o)]+@dividers[1..-1].map{|d| d.r_o}
  end
end

class Latch
  def initialize(size)
    @size = size
    @data = []
    @size.times{|t| @data.push(OneBitMemory.new(Bit.zero))}
  end
  def set(data,w,clear=Bit.zero)
    @data.each_with_index do |d,i|
      d.data = data[i]
      d.edge_triggerd_run(w,clear)
    end
  end
  def get
    @data.map{|m| m.r_o}
  end
end

class SelectorDecoder
  def initialize(size)
    @size = size
  end
  def select(data, address)
    if data.length==@size
      result = []
      out = data.each_with_index do |d,i|
        ar = bit_select(i, address)
        r = Gate.and(d,ar[0])
        (ar.size-1).times{|i| r=Gate.and(r,ar[i+1])}
        result.push(r)
      end
      result.inject(Bit.zero){|s,r| Gate.or(s,r)}
    end
  end
  def decode(write, address)
    result = []
    @size.times do |i|
      ar = bit_select(i, address)
      r = Gate.and(write,ar[0])
      (ar.size-1).times{|i| r=Gate.and(r,ar[i+1])}
      result.push(r)
    end
    result
  end
  def bit_select(i, address)
    ar = []
    a_ar = i.to_s(2).split("").reverse
    (address.size-a_ar.size).times{|t| a_ar.push("0")}
    a_ar.each_with_index{|a,j| a=="1" ? ar.push(address[j]) : ar.push(Gate.not(address[j]))}
    return ar
  end
end

class RandomAccessMemory
  def initialize(size)
    @selector = SelectorDecoder.new(size)
    @data = []
    size.times do |i|
      @data.push(OneBitMemory.new)
    end
  end
  def set(address, data_in, write)
    w = @selector.decode(write, address)
    w.each_with_index do |o,i|
      @data[i].data = data_in
      @data[i].edge_triggerd_run(o)
    end
  end
  def get(address)
    @selector.select(@data.map{|d| d.r_o}, address)
  end
end

class RandomAccessMemoryArray
  def initialize(size,bit_size)
    @ram = []
    bit_size.times do
      @ram.push(RandomAccessMemory.new(size))
    end
  end
  def set(address, data, write)
    @ram.each_with_index{|r,i| r.set(address, data[i], write)}
  end
  def get(address)
    @ram.map{|r| r.get(address)}
  end
end
# exp = 10
# f = FreqDivider.new(exp)
# ram = RandomAccessMemoryArray.new(2**exp,8)
# adr = Adder.to_bits(7)
# (exp-adr.length).times{|t| adr.push(Bit.zero)}
# ram.set(adr,[Bit.one,Bit.zero,Bit.one,Bit.zero,Bit.one,Bit.zero,Bit.one,Bit.zero],Bit.one)
# 8.times{|t| puts "#{ram.get(f.get_count).map{|r| r.state}}";f.run}




# Gate is a relay powered switch
# Relays are used over switches because they can be controlled by other relays (Gates)
# Memory is used to store state, for control later