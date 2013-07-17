require "if"

module IF
  class REPL
    attr_reader :story
  
    def initialize(config={}, &block)
      @input = config[:input] || STDIN
      @output = config[:output] || STDOUT
      
      if config[:file]
        @story = IF::Story.load config[:file], config
      elsif block
        @story = IF::Story.new config, &block
      end
    end
    
    def run
      catch :quit do
        step until false
      end
    end
    
    def step
      input = @input.gets.chop
      
      matchers = @story.verbs.map do |v|
        v.get_matcher objects: @story.objects
      end
      
      matcher = matchers.find do |m|
        m.match input
      end
      
      match = matcher.match input
      
      context = IF::Context.new(nil)
      context._story = @story
       
      context.instance_exec(*match.args, &match.proc)
    end
  end
end