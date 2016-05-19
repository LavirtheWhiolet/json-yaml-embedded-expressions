# encoding: UTF-8

# 
# Refines {Hash} so it behaves like following:
# - <code>hash.xxx</code> is the same as <code>hash["xxx"]</code>
# - <code>hash.xxx = y</code> is the same as <code>hash["xxx"] = y</code>
# 
module EasyHash
  
  class ::Hash
    
    def method_missing(method_id, *args, &block)
      if method_id.to_s.end_with? '=' and args.size == 1 and block.nil? then
        self[method_id.to_s.chop] = args.first
      elsif args.size == 0 and block.nil? then
        self[method_id.to_s]
      else
        super
      end
    end
    
  end
  
end
