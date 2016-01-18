require "./memory"

class Computer

end
size = 8
c = Computer.new

a = Adder.new(size)
l = Latch.new(size)
data = []
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])
data.push([Bit.one,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero,Bit.zero])

# l.set(a.add(v1,v2),Bit.one)
# l.set(a.add(v1,v2),Bit.zero)
# l.set(a.add(l.get,v3),Bit.one)
# l.set(a.add(l.get,v3),Bit.zero)
# l.set(a.add(l.get,v4),Bit.one)
# l.set(a.add(l.get,v4),Bit.zero)
# l.set(a.add(l.get,v5),Bit.one)
# l.set(a.add(l.get,v5),Bit.zero)

# puts "#{l.get.map{|m| m.state}}"

exp = 10
f = FreqDivider.new(exp)
ram = RandomAccessMemoryArray.new(2**exp,size)

data.each_with_index do |d,i|
  adr = Adder.to_bits(i+10)
  (exp-adr.length).times{|t| adr.push(Bit.zero)}
  ram.set(adr,d,Bit.one)
  # puts "#{ram.get(adr).map{|m| m.state}} #{Adder.to_number(adr)}"
end

20.times{|t| puts "#{ram.get(f.get_count).map{|r| r.state}} #{Adder.to_number(f.get_count)}";f.run}

# adr = Adder.to_bits(2)
# (exp-adr.length).times{|t| adr.push(Bit.zero)}
# puts "#{ram.get(adr).map{|m| m.state}}"

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
