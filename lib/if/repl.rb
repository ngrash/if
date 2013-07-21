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
    
    def write(text)
      @story.write text
    end
    
    def write_room(room_context)
      write room_context.description
        
      room_context.objects.each do |object_context|
        next if object_context.moved?
      
        object = object_context._entity
        case object.initial
        when String
          write object.initial
        when Proc
          object_context.instance_eval &object.initial
        end
      end
    end
    
    def step
      player_context = @story.get_context(@story.player)
      if player_context && player_context.room
        write_room(player_context.room)
      end
      
      print "> "
      input = @input.gets.chop
      
      matchers = @story.verbs.map do |v|
        v.get_matcher objects: @story.objects
      end
      
      match = nil
      matchers.find { |m| match = m.match input }
      
      if match
        context = IF::Context.new(@story, nil)
        context.instance_exec(*match.args, &match.proc)
      else
        write "What do you mean?"
      end
    end
  end
end