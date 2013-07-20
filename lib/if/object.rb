require "if/entity"

module IF
  class Object < Entity
    attr_reader :types
  
    def initialize(id, name, config=nil, &block)
      config ||= {}
      
      @types = []
      
      @initial = config[:initial]
      
      super
      
      @original_parent = parent
      
      is *config[:types] if config[:types]
      actions &config[:actions] if config[:actions]
    end
    
    def initial(text=nil, &block)
      return @initial unless text || block
      @initial = text || block
    end
    
    def actions(&block)
      return @actions unless block
      @actions = block
    end
    
    def is(*type_ids)
      type_ids.each do |type|
        @types << type unless @types.include? type
      end
    end
    
    def moved?
      @original_parent != parent
    end
    
    def is?(type_id)
      @types.include? type_id
    end
  end
end