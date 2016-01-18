require "./memory"

class Computer
  def initialize(size,exp)
    @size = size
    @adder = Adder.new(size)
    @latch = Latch.new(size)
    @exp = exp
    @ram = RandomAccessMemoryArray.new(2**exp,size)
    @freqdiv = FreqDivider.new(exp)
  end

  def set_data(data,offset)
    data.each_with_index do |d,i|
      adr = Adder.to_bits(i+offset)
      (@exp-adr.length).times{|t| adr.push(Bit.zero)}
      @ram.set(adr,d,Bit.one)
    end
  end

  def read(amt)
    amt.times do |i|
      puts "#{@ram.get(get_address(i)).map{|r| r.state}} #{i}"
    end
    nil
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

  def jump(address)
    @freqdiv.set_count(address)
  end

  def get_address(int)
    adr = Adder.to_bits(int)
    (@exp-adr.length).times{|t| adr.push(Bit.zero)}
    adr
  end
  def run(int)
    count = 0
    code = nil
    while count<int && code!=255
      code = Adder.to_number(@ram.get(@freqdiv.get_count))
      @freqdiv.run
      address_1 = @ram.get(@freqdiv.get_count)
      @freqdiv.run
      address_2 = @ram.get(@freqdiv.get_count)
      @freqdiv.run
      address = address_1+address_2
      case code
      when 10
        load(address[0..@exp-1])
      when 11
        store(address[0..@exp-1])
      when 20
        add(address[0..@exp-1])
      when 30
        jump(address[0..@exp-1])
      else
      end
      count += 1
    end
  end
end

size = 8
c = Computer.new(8,10)

data = []
# Code
data.push(c.get_address(10)) #0  --
data.push(c.get_address(15)) #1
data.push(c.get_address(0))  #2
data.push(c.get_address(20)) #3  --
data.push(c.get_address(16)) #4
data.push(c.get_address(0))  #5
data.push(c.get_address(20)) #6  --
data.push(c.get_address(17)) #7
data.push(c.get_address(0))  #8
data.push(c.get_address(11)) #9  --
data.push(c.get_address(18)) #10
data.push(c.get_address(0))  #11
data.push(c.get_address(30)) #12 --
data.push(c.get_address(19)) #13
data.push(c.get_address(0))  #14
# Data
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])  #15
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])  #16
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])  #17
data.push([Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero]) #18
# Code
data.push(c.get_address(10))  #19
data.push(c.get_address(32))  #20
data.push(c.get_address(0))   #21
data.push(c.get_address(20))  #22
data.push(c.get_address(33))  #23
data.push(c.get_address(0))   #24
data.push(c.get_address(20))  #25
data.push(c.get_address(34))  #26
data.push(c.get_address(0))   #27
data.push(c.get_address(11))  #28
data.push(c.get_address(35))  #29
data.push(c.get_address(0))   #30
data.push(c.get_address(255)) #31
# Data
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])  #32
data.push([Bit.one,Bit.zero,Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])   #33
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])  #34
data.push([Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero]) #35

c.set_data(data,0)

c.run(36)

puts "#{c.read(36)}"

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
