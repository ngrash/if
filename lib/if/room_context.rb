require "if/context"
require "if/room"

module IF
  class RoomContext < EntityContext
    def initialize(story, room)
      super(story, room)
    end
  
    def objects
      @_entity.objects.inject([]) do |all, object| 
        object_context = @_story.get_context object
        all << object_context
        all << object_context.objects
      end.flatten
    end
    
    Room::Directions.each do |direction|
      define_method "#{direction}" do
        @_entity.exits[direction]
      end
    end
  end
end