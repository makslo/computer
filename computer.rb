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

  def load(address)
    @latch.set(@latch.get,Bit.zero)
    @latch.set(@ram.get(address),Bit.one)
  end

  def store(address)
    @ram.set(address,@latch.get,Bit.one)
  end

  def add(address)
    @latch.set(@latch.get,Bit.zero)
    @latch.set(@adder.add(@latch.get,@ram.get(address)),Bit.one)
  end

  def get_address(int)
    adr = Adder.to_bits(int)
    (@exp-adr.length).times{|t| adr.push(Bit.zero)}
    adr
  end
  def run(int)
    int.times do |i|
      code = Adder.to_number(@code.get(@freqdiv.get_count))
      @freqdiv.run
      address_1 = @code.get(@freqdiv.get_count)
      @freqdiv.run
      address_2 = @code.get(@freqdiv.get_count)
      @freqdiv.run
      address = address_1+address_2
      case code
      when 10
        load(address[0..@exp-1])
      when 11
        store(address[0..@exp-1])
      when 20
        add(address[0..@exp-1])
      else
      end
    end
  end
end

size = 8
c = Computer.new(8,10)

data = []
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])

c.set_data(data,0)

code = []
code.push(c.get_address(10))
code.push(c.get_address(0))
code.push(c.get_address(0))
code.push(c.get_address(20))
code.push(c.get_address(1))
code.push(c.get_address(0))
code.push(c.get_address(20))
code.push(c.get_address(2))
code.push(c.get_address(0))
code.push(c.get_address(11))
code.push(c.get_address(6))
code.push(c.get_address(0))
code.push(c.get_address(10))
code.push(c.get_address(3))
code.push(c.get_address(0))
code.push(c.get_address(20))
code.push(c.get_address(4))
code.push(c.get_address(0))
code.push(c.get_address(20))
code.push(c.get_address(5))
code.push(c.get_address(0))
code.push(c.get_address(11))
code.push(c.get_address(7))
code.push(c.get_address(0))

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
