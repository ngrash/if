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
      player_context = @story.get_context(@story.player)
      
      if player_context && player_context.room
        @story.write player_context.room.description
        
        case @story.player.parent.initial
        when String
          @story.write @story.player.parent.initial
        when Proc
          player_context.room.instance_eval &@story.player.parent.initial
        end
        
        player_context.room.objects.each do |object_context|
          object = @story.get_object(object_context.id)
          case object.initial
          when String
            @story.write object.initial
          when Proc
            object_context.instance_eval &object.initial
          end
        end
      end
      
      print "> "
      input = @input.gets.chop
      
      matchers = @story.verbs.map do |v|
        v.get_matcher objects: @story.objects
      end
      
      matcher = matchers.find do |m|
        m.match input
      end
      
      if matcher
        match = matcher.match input
      
        context = IF::Context.new(@story, nil)
        context.instance_exec(*match.args, &match.proc)
      else
        @story.write "What do you mean?"
      end
    end
  end
end