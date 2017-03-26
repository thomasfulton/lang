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

  def initialize(input)
    @input = input
    @keywords = ['print', 'var']
  end

  def keyword?(string)
    @keywords.include? string
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

  def str_start?(ch)
    ch == '"'
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

  def read_num()
    LexerToken.new(:num, read_while(Proc.new { |ch| digit?(ch) }))
  end

  def read_id()
    str = read_while(Proc.new { |ch| id?(ch) })
    if keyword?(str)
      LexerToken.new(:kw, str)
    else
      LexerToken.new(:var, str)
    end
  end

  def read_op()
    LexerToken.new(:op, read_while(Proc.new { |ch| op?(ch) }))
  end

  def read_str()
    str = @input.peek()
    ch = @input.next()
    while ch != '"'
      str += ch
      ch = @input.next()
    end
    str += ch
    @input.next()
    LexerToken.new(:str, str)
  end

  def read_next()
    read_while(Proc.new { |ch| whitespace?(ch) })

    if @input.eof?()
      return nil
    end

    ch = @input.peek()

    if digit?(ch)
      return read_num()
    end

    if id_start?(ch)
      return read_id()
    end

    if op?(ch)
      return read_op()
    end

    if str_start?(ch)
      return read_str()
    end

    @input.croak("Can't handle character: " + ch)
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
    if ch == "\n"
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

  def croak(message)
    fail "#{message} (#{@line}:#{@col})"
  end
end

lexer = Lexer.new(InputStreamer.new(File.read('source.l')))

while !lexer.eof() do
  puts(lexer.next())
end
