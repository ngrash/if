require "if"

module IF
  class Context
    attr_reader :_story, :_entity
  
    def initialize(story, entity)
      @_story, @_entity = story, entity
    end
    
    def _get_entity(id_or_context)
      context = _get_context(id_or_context)
      context._entity if context
    end
    
    def _get_context(id_or_context)
      return id_or_context unless id_or_context.is_a?(Symbol)
      id = id_or_context
      object(id) || room(id)
    end
    
    def player
      @_story.get_context(@_story.player)
    end
    
    def object(id)
      object = @_story.get_object(id)
      @_story.get_context(object) if object
    end
    
    def room(id)
      room = @_story.get_room(id)
      @_story.get_context(room) if room
    end
    
    def write(text)
      @_story.write text
    end
  end
end