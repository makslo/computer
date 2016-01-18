require "./memory"

class Computer
  def initialize(size,exp)
    @size = size
    @adder = Adder.new(size)
    @latch = Latch.new(size)
    @exp = exp
    @ram = RandomAccessMemoryArray.new(2**exp,size)
    @code = RandomAccessMemoryArray.new(2**exp,size)
    @freqdiv = FreqDivider.new(exp)
  end

  def set_data(data,offset)
    set(data,offset,@ram)
  end

  def set_code(data,offset)
    set(data,offset,@code)
  end

  def set(data,offset,target)
    data.each_with_index do |d,i|
      adr = Adder.to_bits(i+offset)
      (@exp-adr.length).times{|t| adr.push(Bit.zero)}
      target.set(adr,d,Bit.one)
    end
  end

  def read(amt)
    amt.times do |i|
      puts "#{@ram.get(get_address(i)).map{|r| r.state}} #{i}"
    end
  end

  def load
    @latch.set(@latch.get,Bit.zero)
    @latch.set(@ram.get(@freqdiv.get_count),Bit.one)
  end

  def store
    @ram.set(@freqdiv.get_count,@latch.get,Bit.one)
  end

  def add
    @latch.set(@latch.get,Bit.zero)
    @latch.set(@adder.add(@latch.get,@ram.get(@freqdiv.get_count)),Bit.one)
  end

  def get_address(int)
    adr = Adder.to_bits(int)
    (@exp-adr.length).times{|t| adr.push(Bit.zero)}
    adr
  end
  def run(int)
    int.times do |i|
      code = Adder.to_number(@code.get(@freqdiv.get_count))
      case code
      when 10
        load
      when 11
        store
      when 20
        add
      else
      end
      @freqdiv.run
    end
  end
end

size = 8
c = Computer.new(8,10)

data = []
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])

c.set_data(data,0)

code = []
code.push(c.get_address(10))
code.push(c.get_address(20))
code.push(c.get_address(20))
code.push(c.get_address(11))
code.push(c.get_address(10))
code.push(c.get_address(20))
code.push(c.get_address(20))
code.push(c.get_address(11))

c.set_code(code,0)

c.run(20)

puts "#{c.read(20)}"

# Code
# 10 Load
# 11 Store
# 20 Add
# 21 Subtract
# 22 Add with barry
# 23 Subtract with borrow
# 30 Jump
# 31 Jump if zero
# 32 Jump if carry
# 33 Jump if not zero
# 34 Jump if not carry
# FF halt
