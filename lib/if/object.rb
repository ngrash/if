require "if/entity"

module IF
  class Object < Entity
    def initialize(id, name, config=nil, &block)
      config ||= {}
      
      @types = []
      @actions = ActionsContext.new
      
      is *config[:types] if config[:types]
      actions &config[:actions] if config[:actions]
      
      super
    end
    
    def actions(&block)
      return @actions unless block
      @actions.instance_eval &block
    end
    
    def is(*type_ids)
      type_ids.each do |type|
        @types << type unless @types.include? type
      end
    end
    
    def is?(type_id)
      @types.include? type_id
    end
    
    class ActionsContext
      
    end
  end
end