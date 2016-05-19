
module EmbeddedExpressions
  
  # Resolves embedded expressions in +data+.
  # 
  # +data+ is a tree, its nodes are {Array}s and {Hash}es, its leaves are
  # arbitrary {Object}s. Subnodes and leaves are stored as {Array}s' items or
  # as {Hash}es' values.
  # 
  # This function does the following:
  # 1. For each node in +data+ it sets up {BackReferences}: sets
  #    {BackReferences#parent} to the containing node ({Hash} or {Array}) and
  #    {BackReferences#top} to +data.
  # 2. Then for each leaf which is a {String} of the form +"=expr"+ and not of
  #    the form "==expr" it evaluates +expr+ in context of the containing node
  #    and replaces the leaf with the +expr+'s value. +expr+ which is required
  #    by another +expr+ is evaluated first.
  # 
  # @return +data+ with embedded expressions resolved as described above.
  # 
  # @example
  #   
  #   d = {
  #     "a" => [
  #       "= parent['b'] + self.size",
  #       "== ignored"
  #     ],
  #     "b" => "= self['c'] * 2",
  #     "c" => 20
  #   }
  #   EmbeddedExpressions.resolve!(d)
  #   puts d.inspect
  #     # {
  #     #   "a" => [
  #     #     42,
  #     #     "== ignored"
  #     #   ],
  #     #   "b" => 40,
  #     #   "c" => 20
  #     # }
  # 
  def resolve!(data)
    # Replace all "=expr" strings with {EmbeddedExpression}s.
    y = lambda do |data|
      case data
      when Array
        for i in 0...data.size
          data[i] = y.(data[i])
        end
        data
      when Hash
        for key in data.keys
          data[key] = y.(data[key])
        end
        data
      when /^\=\=/
        data
      when /^\=/
        EmbeddedExpression.new(&eval("proc do \n #{data[1..-1]} \n end"))
      else
        data
      end
    end
    y.(data)
    # Populate {BackReferences} and {EmbeddedExpression#__context__}.
    y = lambda do |data, parent, top|
      case data
      when Array
        data.parent = parent
        data.top = top
        data.each { |item| y.(item, data, top) }
      when Hash
        data.parent = parent
        data.top = top
        data.values.each { |value| y.(value, data, top) }
      when EmbeddedExpression
        data.__context__ = parent
      end
    end
    y.(data, nil, data)
    # Replace all {EmbeddedExpression}s with their values.
    y = lambda do |data|
      case data
      when Array
        for i in 0...data.size
          data[i] = y.(data[i])
        end
        data
      when Hash
        for key in data.keys
          data[key] = y.(data[key])
        end
        data
      when EmbeddedExpression
        data.__value__
      else
        data
      end
    end
    y.(data)
    #
    return data
  end
  
  module_function :resolve!
  
  module BackReferences
    
    attr_accessor :parent
    
    attr_accessor :top
    
  end
  
  class ::Hash
    
    include BackReferences
    
  end
  
  class ::Array
    
    include BackReferences
    
  end
  
  private
  
  # @!visibility private
  class EmbeddedExpression < BasicObject
    
    def initialize(&computation)
      @context = nil
      @expr = computation
      @expr_resolved = false
    end
    
    def __context__=(value)
      @context = value
    end
    
    def __value__
      if @expr_resolved then
        return @expr
      else
        @expr = @context.instance_eval(&@expr)
        @expr_resolved = true
        @context = nil
        return @expr
      end
    end
    
    def method_missing(method_id, *args, &block)
      __value__.__send__(method_id, *args, &block)
    end
    
  end
  
end
