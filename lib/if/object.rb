require "if/entity"

module IF
  class Object < Entity
    def initialize(id, name, config=nil, &block)
      config ||= {}
      
      @types = []
      
      config = config.merge(context: Context.new(self))
      
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
    
    class Context < Entity::Context
      def parent
        @_entity.parent.context
      end
      
      def room(id=nil)
        if id.nil?
          parent = @_entity
          until
            parent = parent.parent
          end until parent.is_a? IF::Room
          parent.context if parent
        else
          super
        end
      end
      
      def move_to(id_or_context)
        entity = _get_entity id_or_context
        @_entity.move_to(entity)
      end
      
      def is?(type)
        @_entity.is? type
      end
      
      def in?(id_or_context)
        entity = _get_entity id_or_context
        entity.objects.include?(@_entity)
      end
      
      def within?(id_or_context)
        entity = _get_entity id_or_context
        entity.objects(true).include?(@_entity)
      end
    end
  end
end