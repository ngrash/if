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
    
    def children
      @_entity.objects.map { |o| @_story.get_context(o) }
    end
    
    def child_objects
      children.inject([]) do |list, child|
        list << child
        list << child.objects
        list.flatten
      end
    end
    
    def contains?(id_or_context)
      children.include? _get_context(id_or_context)
    end
  end
end