#!/usr/bin/env ruby

require 'circ_buf'

class LuhnChecker < CircularBuffer
  def initialize(len)
    @len = len
    super(len, 3*len)
  end

  def is_cc_num
#    puts "LuhnChecker.is_cc_num(#{@len})"
#    puts self
    return false if size < @len

    count = 0
    sum = 0
    is_cc_num = false
    i = 0
    j = @len % 2
    remain = @len
    loop do
      x = at(i)
      i += 1
      break if (i == size)
      next if ((x < 48) or (x > 57))
      x -= 48
      y = 2 * x
      n = (count % 2 == j) ? ((y % 10) + (y / 10)) : x
      sum += n
#       puts "i=#{i}, x=#{x}, y=#{y}, next=#{n}, sum=#{sum}\n"
      count += 1
      is_cc_num = ((sum % 10) == 0) and sum > 0
      remain -= 1
      break if (remain == 0)
    end
#     puts "LuhnChecker.is_cc_num(#{@len}): #{is_cc_num}"
    is_cc_num
  end

  def push_char(c)
    put(c)
  end

  def cc_num
    self.inject('') do |w,c|
      w << c if ((c >= 48) && (c < 58))
      w
    end
  end
end

def contains_cc_nums(input, file)
  lch14 = LuhnChecker.new(14)
  lch15 = LuhnChecker.new(15)
  lch16 = LuhnChecker.new(16)

  seen_cc_num = false
  masked = ''

  input.each_byte do |b|
    if (b < 48 or b > 57)
      masked << b
      file.write("\nNext masked: #{masked}\n")
#       if (b != 32 and b != 45)
  #       file.write("Resetting!\n")
    #     lch14.reset
      #   lch15.reset
#         lch16.reset
  #     end
    #   next
    end
    lch14.push_char(b)
    lch15.push_char(b)
    lch16.push_char(b)

    if lch14.is_cc_num
      seen_cc_num = true
      file.write("LuhnChecker(14) found a valid CC num:#{lch14.cc_num}\n") 
      masked << 'X'*14
    elsif lch15.is_cc_num
      seen_cc_num = true
      file.write("LuhnChecker(15) found a valid CC num:#{lch15.cc_num}\n")
      masked << 'X'*15
    elsif lch16.is_cc_num
      seen_cc_num = true
      file.write("LuhnChecker(16) found a valid CC num:#{lch16.cc_num}\n")
      masked << 'X'*16
    end
  end
  {:flag => seen_cc_num, :masked => masked}
end

file = File.new("log", "w")
file.write "Starting\n"

ARGF.each do |line|
  file.write "\nread: #{line.length} bytes::#{line}\n"
  l = line.strip
  ret = contains_cc_nums(l, file)
  if ret[:flag]
    puts ret[:masked]
  else
    puts line
  end
end
file.write "Done"
file.close

