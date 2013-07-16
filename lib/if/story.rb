module IF
  class Story
    attr_reader :verbs, :player
  
    def initialize(config=nil, &block)
      config ||= {}
    
      @objects = {}
      @rooms = {}

      @verbs = []
      @player = IF::Object.new :player, "Player"
      
      config[:rooms].each do |room|
        add_room room
      end if config[:rooms]
      
      config[:verbs].each do |verb|
        @verbs << verb unless @verbs.include? verb
      end if config[:verbs]
      
      if block
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end
    
    def self.load(story_file)
      story_definition = File.read(story_file)
      story = IF::Story.new
      story.instance_eval(story_definition, story_file)
      story
    end
    
    def get_object(id)
      @objects[id]
    end
    
    def get_room(id)
      @rooms[id]
    end
    
    def add_room(room)
      fail if @rooms[room.id] || @objects[room.id]
      @rooms[room.id] = room
      
      room.context._story = self 
      room.objects(true).each do |o|
        o.context._story = self
        
        fail if @objects[o.id] || @rooms[o.id]
        @objects[o.id] = o
      end
    end
    
    def rooms
      @rooms.values
    end
    
    def objects
      @objects.values
    end
    
    def room(id, name, &block)
      add_room Room.new(id, name, &block)
    end
    
    def verb(*names, &block)
      @verbs << Verb.new(*names, &block)
    end
  end
end