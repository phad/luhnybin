#!/usr/bin/env ruby

def is_cc_num(input, file)
  count = 0
  sum = 0
  masked = ''
  is_cc_num = false
  input.reverse.each_byte do |b|
    if (b < 48 or b > 57)
      masked += b.chr
      file.write("now have #{masked}\n")
      next
    end
    masked += 'X'
    file.write("now have #{masked}\n")

    x = b.to_i - 48
    y = 2 * x
    sum += (count % 2 == 1) ? ((y % 10) + (y / 10)) : x
    count += 1

    if count >= 14 and count <= 16
      is_cc_num = ((sum % 10) == 0) and sum > 0
    end
  end
  masked.reverse!
  file.write("now have #{masked}\n")
  {:flag => is_cc_num, :masked_num => masked}
end

file = File.new("log", "w")
file.write "Starting"

ARGF.each do |line|
  file.write "read: #{line.length} bytes::#{line}"
  l = line.strip
  ret = is_cc_num(l, file)
  if ret[:flag]
    puts ret[:masked_num]
  else
    puts line
  end
end
file.write "Done"
file.close

