require "if/context"

module IF
  class ObjectContext < EntityContext
    def initialize(story, object)
      super(story, object)
    end
  
    def parent
      @_story.get_context(@_entity.parent)
    end
    
    def room(id=nil)
      if id
        super
      else
        parent = @_entity
        until
          parent = parent.parent
        end until parent.is_a? IF::Room
        @_story.get_context(parent) if parent
      end
    end
    
    def move_to(id_or_context)
      entity = _get_entity id_or_context
      @_entity.move_to(entity)
    end
    
    def is?(type)
      @_entity.is? type
    end
    
    def in?(id_or_context)
      entity = _get_entity id_or_context
      entity.objects.include?(@_entity)
    end
    
    def within?(id_or_context)
      entity = _get_entity id_or_context
      entity.objects(true).include?(@_entity)
    end
  end
end