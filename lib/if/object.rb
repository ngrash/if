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
      @context.instance_eval &block
    end
    
    def action(name, &block)
      id = nil
      if name.is_a? Symbol
        id = name
      else
        id = name.gsub(/\s+/, "_").to_sym
      end
      
      meta = class << @context; self; end
      meta.send(:define_method, id, &block)
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