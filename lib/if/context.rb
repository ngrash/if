module IF
  class Context
    attr_accessor :_this, :_objects, :_player, :_rooms
  
    def initialize(config={})
      @_this = config[:this]
      @_objects = config[:objects]
      @_player = config[:player]
      @_rooms = config[:rooms]
    end
  
    def object(id)
      object = @_objects.find { |object| object.id == id }
      object.context
    end
    
    def player
      @_player.context
    end
    
    def room(room=nil)
      @_player.parent if room.nil?
    end
    
    def description
      @_this.description
    end
    
    def name
      @_this.name
    end
    
    def move_to(object)
      unless object.is_a? Symbol
        object = object(object)
      end
      @_this.move_to(object)
    end
    
    def write(text)
      puts text
    end
  end
end