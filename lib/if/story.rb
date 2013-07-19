require "set"

module IF
  class Story
    attr_reader :player, :info
  
    def initialize(config=nil, &block)
      config ||= {}

      @types = {}
      @objects = {}
      @rooms = {}
      @contexts = {}
      @verbs = Set.new
      
      @player = IF::Object.new :player, "Player"
      
      @info = config[:info] || StoryInfo.new
      @output = config[:output] || STDOUT
      add_types config[:types] if config[:types]
      add_rooms config[:rooms] if config[:rooms]
      @verbs += config[:verbs] if config[:verbs]
      
      if block
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end
    
    def verbs
      @verbs.to_a
    end
    
    def types
      @types.values
    end
    
    def self.load(story_file, config={})
      story_definition = File.read story_file
      story = IF::Story.new config
      story.instance_eval story_definition, story_file
      story
    end
    
    def get_type(id)
      @types[id]
    end
    
    def get_object(id)
      @objects[id]
    end
    
    def get_room(id)
      @rooms[id]
    end
    
    def get_entity(id)
      get_room(id) || get_object(id)
    end
    
    def get_context(id_or_entity)
      entity = id_or_entity.is_a?(Symbol) ? get_entity(id_or_entity) : id_or_entity
      @contexts[entity.id] ||= case entity
                               when IF::Room; IF::RoomContext.new(self, entity)
                               when IF::Object
                                context = IF::ObjectContext.new(self, entity)
                                entity.types.each do |t|
                                  if type = get_type(t)
                                    context.instance_eval &type.actions
                                  end
                                end
                                context.instance_eval &entity.actions if entity.actions
                                context
                              else; IF::Context.new(self, entity)
                              end
    end
    
    def add_types(types)
      types.each { |t| add_type t }
    end
    
    def add_type(type)
      validate_uniqueness(type.id)
      @types[type.id] = type
    end
    
    def add_rooms(rooms)
      rooms.each { |r| add_room r }
    end
    
    def add_room(room)
      validate_uniqueness(room.id)
      @rooms[room.id] = room
      
      room.objects(true).each do |o|
        validate_uniqueness(o.id)
        @objects[o.id] = o
      end
      
      if room.id == @info.start
        @player.move_to room
      end
    end
    
    def validate_uniqueness(id)
      fail if get_entity(id) || get_type(id)
    end
    
    def rooms
      @rooms.values
    end
    
    def objects
      @objects.values
    end
    
    def story(&block)
      @info = StoryInfo.new(&block)
    end
    
    def type(id, &block)
      add_type Type.new(id, &block)
    end
    
    def room(id, name, &block)
      add_room Room.new(id, name, &block)
    end
    
    def verb(*names, &block)
      @verbs << Verb.new(*names, &block)
    end
    
    def write(text)
      @output.puts text
    end
  end
end