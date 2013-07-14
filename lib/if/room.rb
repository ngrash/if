require "if/entity"

module IF
  class Room < Entity
    attr_accessor :exits
  
    def initialize(id, name, config=nil, &block)
      config ||= {}
      
      @exits = {}
      
      Directions.each do |direction|
        exit = Directions.to_exit(direction)
        @exits[direction] = config[exit] if config[exit]
      end
      
      super
    end
    
    module Directions
      DIRECTIONS = [:north, :east, :south, :west]
      
      extend Enumerable
      
      def self.to_exit(direction)
        "#{direction}_to".to_sym
      end
      
      def self.each
        DIRECTIONS.each do |direction|
          yield direction
        end
      end
    end
    
    Directions.each do |direction|
      define_method "#{direction}_to" do |room_id|
        @exits[direction] = room_id
      end
    end
  end
end