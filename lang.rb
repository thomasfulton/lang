class ASTNode
end

class ASTLiteralNode < ASTNode
  attr_accessor :type
  attr_accessor :value
end

class ASTIntNode < ASTLiteralNode
  def initialize()
    @type = :int
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
    @operator = :plus
  end
end

class ASTAssignmentNode < ASTBinaryOperatorNode
  def initialize()
    @operator = :equals
  end
end

class LexerToken
  attr_accessor :type
  attr_accessor :value

  def initialize(type, value)
    @type = type
    @value = value
  end

  def to_s
    "LexerToken(#{type}, #{value})"
  end
end

class Lexer

  @current = nil

  @input

  def initialize(input)
    @input = input
  end

  def keyword?(string)
    @keyword.include? string
  end

  def digit?(ch)
    ch =~ /[[:digit:]]/
  end

  def id_start?(ch)
    ch =~ /[a-z_]/
  end

  def id?(ch)
    id_start?(ch) || digit?(ch)
  end

  def op?(ch)
    ch =~ /[+\-*\/%=&|<>!?]/
  end

  def whitespace?(ch)
    ch =~ /[[:space:]]/
  end

  def read_while(proc)
    str = ""
    ch = @input.peek()
    while !@input.eof?() && proc.call(ch)
      str += ch
      ch = @input.next()
    end
    str
  end

  def read_number()
    read_while(Proc.new { |ch| digit?(ch) })
  end

  def read_identifier()
    read_while(Proc.new { |ch| id?(ch) })
  end

  def read_op()
    read_while(Proc.new { |ch| op?(ch) })
  end

  def read_next()
    read_while(Proc.new { |ch| whitespace?(ch) })

    if @input.eof?()
      return nil
    end

    ch = @input.peek()

    if digit?(ch)
      return LexerToken.new(:number, read_number())
    end

    if id_start?(ch)
      return LexerToken.new(:identifier, read_identifier())
    end

    if op?(ch)
      return LexerToken.new(:op, read_op())
    end

    @input.fail("Can't handle character: " + ch)
    return nil
  end

  def peek()
    if @current == nil
      @current = read_next
    end
    @current
  end

  def next()
    tok = @current
    @current = nil
    tok || read_next()
  end

  def eof()
    peek() == nil
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

  def peek(index=0)
    @source[@pos + index]
  end

  def eof?()
    @pos >= @source.length
  end

  def fail(message)
    fail message + ' (' + line + ':' + col + ')'
  end
end

lexer = Lexer.new(InputStreamer.new(File.read('source.l')))

while !lexer.eof() do
  puts(lexer.next())
end
