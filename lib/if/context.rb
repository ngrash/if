require "if"

module IF
  class Context
    attr_accessor :_story, :_entity
    
    def initialize(entity)
      @_entity = entity
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
    
    def parent
      @_entity.parent.context
    end
    
    def player
      @_story.player.context
    end
    
    def object(id)
      object = @_story.get_object(id)
      object.context if object
    end
    
    def description
      @_entity.description
    end
    
    def name
      @_entity.name
    end
    
    def id
      @_entity.id
    end
    
    def move_to(id_or_context)
      entity = _get_entity id_or_context
      @_entity.move_to(entity)
    end
    
    def contains?(id_or_context)
      object = _get_entity id_or_context
      @_entity.objects.include?(object)
    end
    
    def in?(id_or_context)
      entity = _get_entity id_or_context
      entity.objects.include?(@_entity)
    end
    
    def within?(id_or_context)
      entity = _get_entity id_or_context
      entity.objects(true).include?(@_entity)
    end
    
    def room(id=nil)
      if id.nil?
        parent = @_entity
        until
          parent = parent.parent
        end until parent.is_a? IF::Room
        parent.context if parent
      else
        room = @_story.get_room(id)
        room.context if room
      end
    end
    
    def write(text)
      puts text
    end
  end
end