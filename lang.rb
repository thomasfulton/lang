class ASTNode
end

class ASTLiteralNode < ASTNode
  attr_accessor :type
  attr_accessor :value
end

class ASTIntNode < ASTLiteralNode
  def initialize()
    @type = "int"
  end
end

class ASTVariableNode < ASTNode
    attr_accessor :name
end

class ASTBinaryOperatorNode < ASTNode
  attr_accessor :operator
  attr_accessor :left
  attr_accessor :right
end

class ASTPlusOperatorNode < ASTBinaryOperatorNode
  def initialize()
    @operator = "+"
  end
end

class ASTAssignmentNode < ASTBinaryOperatorNode
  def initialize()
    @operator = "="
  end
end

class InputStreamer

  def initialize(source)
    @source = source
    @pos = 0
    @line = 1
    @col = 0
  end

  def next()
    @pos += 1
    ch = @source[@pos]
    if ch == '\n'
      @col = 0
      @line += 1
    else
      @col += 1
    end
    ch
  end

  def peek()
    @source[@pos]
  end

  def eof()
    @pos >= @source.length
  end

  def fail(message)
    fail message + "line: " + line + " col: " + col
  end
end

input_streamer = InputStreamer.new(File.read("source.l"))

while !input_streamer.eof() do
  puts(input_streamer.peek())
  input_streamer.next()
end
