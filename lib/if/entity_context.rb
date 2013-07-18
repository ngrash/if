require "if/context"

module IF
  class EntityContext < Context
    def initialize(story, entity)
      super(story, entity)
    end
  
    def id
      @_entity.id
    end
    
    def name
      @_entity.name
    end
    
    def description
      @_entity.description
    end
    
    def objects
      []
    end
    
    def contains?(id_or_context)
      object = _get_entity id_or_context
      @_entity.objects.include?(object)
    end
  end
end