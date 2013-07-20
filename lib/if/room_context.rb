require "if/context"
require "if/room"

module IF
  class RoomContext < EntityContext
    def initialize(story, room)
      super(story, room)
    end
  
    def objects
      child_objects
    end
    
    Room::Directions.each do |direction|
      define_method "#{direction}" do
        @_entity.exits[direction]
      end
    end
  end
end