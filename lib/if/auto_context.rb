module IF
  module AutoContext
    def context_method(name, original=nil, options={})
        options[:original] = original || name
        @context_methods ||= {}
        @context_methods[name] = {}
    end
  
    class Base
      def initialize(object)
        context_methods = object.class.instance_variable_get(:@context_methods)
        fail "#{object.class} has no context methods" unless context_methods
        context_methods.each do |name, options|
          metaclass = class << self; self; end
          metaclass.instance_exec(object, name, options) do |object, name, options|
            define_method(name) do |*args|
              args.each_with_index do |arg, index|
                to_type = options[:args][index]
                args[index] = map(arg, to_type)
              end if options[:args]
              
              result = obj.send(options[:original], *args)
              
              if args[:result]
                map(result.class, args[:result])
              else
                result
              end
            end
          end
        end
      end
      
      def map(value, to_type)
        raise TypeError, "Don't know how to map #{value.class} to #{to_type}"
      end
    end
  end
end