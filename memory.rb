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
  def run
    # Have to run the gates a few times to stabilize
    @r_o = Gate.nor(get_r,Gate.nor(get_s,@r_o))
    @s_o = Gate.nor(get_s,Gate.nor(get_r,@s_o))
  end
  def edge_triggerd_run(clock)
    if @clock.state == Bit.zero.state && clock.state == Bit.one.state
      @clock = clock
      @r_o = Gate.nor(get_r,Gate.nor(get_s,@r_o))
      @s_o = Gate.nor(get_s,Gate.nor(get_r,@s_o))
    else
      @clock = clock
    end
  end
end

class Oscillator
  attr_accessor :o
  def initialize
    @o = Bit.zero
  end
  def run
    @o = Gate.not(@o)
  end
end

class FreqDivider
  def initialize
    @o = Oscillator.new
    @m1 = OneBitMemory.new(@o.o)
    @m2 = OneBitMemory.new(@m1.s_o)
    @m3 = OneBitMemory.new(@m2.s_o)
  end
  def run
    puts "#{Adder.to_number([Gate.not(@o.o),@m1.r_o,@m2.r_o,@m3.r_o])} #{[Gate.not(@o.o).state,@m1.r_o.state,@m2.r_o.state,@m3.r_o.state]}"
    @o.run
    @m1.data = @m1.s_o
    @m1.edge_triggerd_run(@o.o)
    @m2.data = @m2.s_o
    @m2.edge_triggerd_run(@m1.s_o)
    @m3.data = @m3.s_o
    @m3.edge_triggerd_run(@m2.s_o)
  end
end

class EightBitMemory
  def set(input,w)
    if input.is_a?(Array) && input.size==8
      @bits = []
      8.times do |i|
        bit = OneBitMemory.new(w)
        bit.data = input[i]
        bit.run
        @bits.push(bit)
      end
      puts "#{@bits.map{|b| b.r_o.state}}"
    end
  end
end

class Selector
  def initialize(size)
    @size = size
  end
  def select(data, address)
    if data.length==@size
      result = []
      out = data.each_with_index do |d,i|
        a_ar = i.to_s(2).split("").reverse
        (address.size-a_ar.size).times{|t| a_ar.push("0")}
        ar = []
        a_ar.each_with_index{|a,j| a=="1" ? ar.push(address[j]) : ar.push(Gate.not(address[j]))}
      
        result.push(Gate.and(Gate.and(d,ar[0]),Gate.and(ar[1],ar[2])))
      end
      result.inject(Bit.zero){|s,r| Gate.or(s,r)}
      
    end
  end
end

s = Selector.new(8)
puts s.select([Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.one,Bit.zero,Bit.zero],[Bit.one,Bit.zero,Bit.one]).state

class RandomAccessMemory
  def eight_to_one
    
  end
end


# Gate is a relay powered switch
# Relays are used over switches because they can be controlled by other relays (Gates)
# Memory is used to store state, for control later