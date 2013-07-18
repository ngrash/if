require "if/entity"

module IF
  class Object < Entity
    def initialize(id, name, config=nil, &block)
      config ||= {}
      
      @types = []
      
      super
      
      is *config[:types] if config[:types]
      actions &config[:actions] if config[:actions]
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
    
    def is?(type_id)
      @types.include? type_id
    end
  end
end