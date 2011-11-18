class CircularBuffer

  include Enumerable

  def initialize(capacity, max_capacity = capacity)
    @initial_capacity = capacity
    @max_capacity = max_capacity
    reset
  end

  def reset
    @capacity = @initial_capacity
    @front = 0
    @back = 0
    @elements = Array.new(capacity)
  end

  def tail
    raise "Empty!" if empty?
    return @elements[(@back - 1) % capacity]
  end

  def head
    raise "Empty!" if empty?
    return @elements[@front]
  end

  def each
    (0 .. size - 1).each {|index| yield at(index) }
  end

  def at(index)
    raise "Bad index #{index}" if (index < 0 or index >= size)
    return @elements[(@front + index) % capacity]
  end

  def modify(index, element)
    raise "Bad index #{index}" if (index < 0 or index >= size)
    @elements[(@front + index) % capacity] = element
  end

  def get
    element = @elements[@front]
    @elements[@front] = nil
    @front = (@front + 1) % @capacity
    return element
  end

  def put(element)
    adjust_front = false
    if full?
      if @capacity < @max_capacity
        grow
      else
        adjust_front = true
      end
    end
    @elements[@back] = element
    @back = (@back + 1) % @capacity
    if (adjust_front)
      @front = (@front + 1) % @capacity
   end
  end

  def full?
    return (@front == @back and @elements[@front] != nil)
  end

  def empty?
    return (@front == @back and @elements[@front] == nil)
  end

  def size
    return 0 if empty?
    return @capacity if full?
    return (@back - @front) % @capacity
  end

  def capacity
    @capacity
  end

  def to_s
    s = "size:#{size}, capacity:#{@capacity}, max_capacity:#{@max_capacity}: "
    @elements.each_with_index do |e,c|
      s += (e == nil ? "(nil)" : "#{e}")
      s += "[F]" if c == @front
      s += "[B]" if c == @back
      s += ", " if c < (@capacity - 1)
    end
    s
  end

  private

  def grow
    new_capacity = [2 * @capacity, @max_capacity].min
    new_elements = Array.new(new_capacity)
    @elements.each_with_index {|e,c| new_elements[c] = e}
    @elements = new_elements
    @back = @capacity
    @capacity = new_capacity
  end

end