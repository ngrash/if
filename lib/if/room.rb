require "if/entity"

module IF
  class Room < Entity
    attr_accessor :exits
  
    def initialize(id, name, config=nil, &block)
      config ||= {}
      
      @exits = {}
      
      Direction.each do |direction|
        exit = Direction.to_exit(direction)
        @exits[direction] = config[exit] if config[exit]
      end
      
      if block_given?
        block.arity < 1 ? instance_eval(&block) : block.call(self)
      end
    end
    
    module Direction
      DIRECTIONS = [:north, :east, :south, :west]
      
      def self.to_exit(direction)
        "#{direction}_to".to_sym
      end
      
      def self.each
        DIRECTIONS.each do |direction|
          yield direction
        end
      end
    end
    
    Direction.each do |direction|
      define_method "#{direction}_to" do |room_id|
        @exits[direction] = room_id
      end
    end
  end
end