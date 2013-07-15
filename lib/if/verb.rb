module IF
  class Verb
    attr_reader :names, :patterns
    
    def initialize(*names, &block)
      @names = names
      
      if block
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end
    
    def with(*args, &block)
      fail unless block
      fail if args.empty?
      
      @patterns ||= {}
      @patterns[args] = block
    end
    
    def alone(&block)
      @patterns ||= {}
      @patterns[[]] = block
    end
    
    def get_matcher(config={})
      Matcher.new config, self
    end
    
    class Matcher
      def initialize(config, verb)
        @expressions = {}
        @config = config
        
        verb.patterns.each do |pattern,block|
          re = "(#{verb.names.join("|")})"
          pattern.each do |part|
            re << " "
            if part == :object
              re << "(#{config[:objects].map{|o|o.names.join("|")}.join("|")})"
            elsif part == :room
              re << "(#{config[:rooms].map{|r|r.names.join("|")}.join("|")})"
            elsif part.is_a? String
              re << part
            elsif part.is_a? Symbol
              re << "(#{config[:objects].find_all{|o| o.is? part}.map{|o|o.names.join("|")}.join("|")})"
            else
              fail
            end
          end          
          @expressions[Regexp.new(re)] = block
        end
      end
    
      def match(text)
        @expressions.each do |expression, block|
          if match = expression.match(text)
            verb = match[1]
            args = match[2...match.length].map { |name| lookup_object(name) }
            return Match.new verb, block, args
          end
        end
        nil
      end
      
      def lookup_object(name)
        (@config[:objects] || [] + @config[:rooms] || []).find { |object| object.names.include? name }
      end
    
      class Match
        attr_reader :verb, :proc, :args
        
        def initialize(verb, proc, args)
          @verb = verb
          @proc = proc
          @args = args
        end
      end
    end
  end
end