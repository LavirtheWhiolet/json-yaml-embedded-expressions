require 'yaml'
require 'embedded_expressions'

module YAML
  
  # @!parse
  #   module EmbeddedExpressions
  #     include ::EmbeddedExpressions
  #   end
  
  # @!visibility private
  EmbeddedExpressions = ::EmbeddedExpressions
  
end
